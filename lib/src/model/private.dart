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


Future<Song> _getSong(int songCode) async {
  Song song = _datastore[Song][songCode];

  if (song == null) {
    logger.finer('Queried Deezer for song: $songCode');
    song = await deezer.getSong(songCode);

    if (song != null) { _datastore.add(song); }
  }

  return song;
}


bool _playthroughSuggestionValid(Song song, Party party) =>
    party.settings.playthroughCap == null || party.playthroughs.length < party.settings.playthroughCap;

void _modifyPlaythrough(Playthrough play, Function callback) {
  Duration prevCompletedDuration = play.completedDuration;

  callback();

  if (play.completedDuration == null || prevCompletedDuration > play.completedDuration) {
    play.completedDuration = prevCompletedDuration;
  }
  else if (play.completedDuration >= play.song.duration) {
    deletePlaythrough(play);
    logger.finer('Completed playthrough: ${play.identity} in party: ${play.party.partyCode}');
  }

  logger.fine('Appected modification to playthrough: ${play.identity}');
}

void _recomputePlaylist(Party party) {
  List l = party.playthroughs.toList(growable: false)
    ..sort((a, b) => b.netVotes - a.netVotes);

  int i = 0;
  for(Playthrough p in l) {
    p.position = i++;
  }
}

bool _playthroughHitVetoCondition(Playthrough play) =>
    play.downvotes / play.party.users.length >= play.party.settings.vetoRatio;