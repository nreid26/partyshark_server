part of model;

int _genValidUserCode() {
  int u = rand_serve.userCode;
  while (_datastore[User].containsIdentity(u)) { u++; }
  return u;
}

String _genValidUsername(Party party) {
  String username;
  int maxAttempts = 10;
  Set<String> takenNames = party.users.map((u) => u.username).toSet();

  do {
    username = rand_serve.username;
    maxAttempts--;
  } while (maxAttempts > 0 && takenNames.contains(username));

  if (maxAttempts == 0) { throw new Exception('Could not generate a unique username for party: ${party.partyCode}'); }
  return username;
}

bool _userCanJoin(Party party) {
  if (party.settings.userCap == null) { return true; }
  return party.users.length < party.settings.userCap;
}


Future<Song> _getSong(int songCode) async {
  Song song = _datastore[Song][songCode];

  if (song == null) {
    logger.finer('Queried Deezer for song: $songCode');
    song = await deezer.getSong(songCode);

    if (song != null) { _datastore.add(song); }
  }

  return song;
}


void _modifyParty(Party party, void callback()) {
  bool prevIsPlaying = party.isPlaying;

  callback();

  if (party.isPlaying == null) {
    party.isPlaying = prevIsPlaying;
  }
}


bool _playthroughSuggestionValid(Song song, Party party) =>
    party.settings.playthroughCap == null || party.playlist.length < party.settings.playthroughCap;

void _modifyPlaythrough(Playthrough play, void callback()) {
  Duration prevCompletedDuration = play.completedDuration;

  callback();

  if (!play.party.isPlaying || play.completedDuration == null || play.completedDuration < prevCompletedDuration ) {
    play.completedDuration = prevCompletedDuration;
  }
  else if (play.completedDuration >= play.song.duration) {
    deletePlaythrough(play);
    logger.finer('Completed playthrough: ${play.identity} in party: ${play.party.partyCode}');
  }

  logger.fine('Appected modification to playthrough: ${play.identity}');
}

void _recomputePlaylist(Party party) {
  if (party.playlist.isEmpty) { return; }

  Playthrough playing = party.playlist.first;
  if (playing.position != 0) { playing = null; }

  party.playlist
    ..remove(playing)
    ..sort((a, b) => b.netVotes - a.netVotes);

  if (playing != null) { party.playlist.insert(0, playing); }

  int i = 0;
  for(Playthrough p in party.playlist) {
    p.position = i++;
  }
}

bool _playthroughHitVetoCondition(Playthrough play) {
  return play.downvotes > play.party.settings.vetoRatio * play.party.users.length;
}


void _modifySettings(SettingsGroup set, void callback()) {
  double prevVetoRatio = set.vetoRatio;
  bool prevVirtualDj = set.usingVirtualDj;

  callback();

  if (set.vetoRatio == null) {
    set.vetoRatio = prevVetoRatio;
  }
  else {
    set.vetoRatio.clamp(0.0, 1.0);
  }

  if (set.usingVirtualDj == null) {
    set.usingVirtualDj = prevVirtualDj;
  }

  logger.fine('Appected modification to settings group: ${set.identity}');
}


void _modifyTransfer(PlayerTransfer trans, void callback()) {
  TransferStatus prevStatus = trans.status;

  callback();

  if (trans.status == TransferStatus.Closed && prevStatus == TransferStatus.Open) {
    trans.requester.party.player = trans.requester;
    trans.closureTime = new DateTime.now();
  }
  else if (prevStatus == TransferStatus.Closed || trans.status == null) {
    trans.status = prevStatus;
  }
}

bool _transferCreationValid(User user) {
  if (user.party.transfers.any((t) => t.status == TransferStatus.Open && t.requester == User)) {
    return false;
  }
  return true;
}