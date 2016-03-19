part of model;

Party createParty() {
  /// Make and store new objects
  SettingsGroup settings = new SettingsGroup();
  _datastore.add(settings);

  Party party = new Party(rand_serve.adminCode, settings);
  _datastore.add(party);

  User user = createUser(party, true);
  if (user == null) { //Bad luck
    _datastore
        ..remove(settings)
        ..remove(party);
    return null;
  }

  party.player = user;
  settings.party = party;

  logger
      ..fine('Created new party: ${party.partyCode}')
      ..fine('Created new user: ${user.userCode}');

  return party;
}

void deleteParty(Party party) {
  _datastore[Party].remove(party);
  _datastore[User].removeAll(party.users);
  _datastore[SettingsGroup].remove(party.settings);
  _datastore[PlayerTransfer].removeAll(party.transfers);

  party.playlist.forEach((play) {
    _datastore[Ballot].removeAll(play.ballots);
    _datastore[Playthrough].remove(play);
  });
}


Playthrough createPlaythrough(Song song, Party party, User suggester) {
  if (!_playthroughSuggestionValid(song, party)) { return null; }

  Playthrough play = new Playthrough(song, party.playlist.length, suggester);
  Ballot ballot = new Ballot(suggester, play, Vote.Up);

  _datastore
    ..add(play)
    ..add(ballot);

  return play
    ..party.playlist.add(play)
    ..ballots.add(ballot);
}

void deletePlaythrough(Playthrough play) {
  play.party.playlist.remove(play);

  _datastore[Ballot].removeAll(play.ballots);
  _datastore[Playthrough].remove(play);

  _recomputePlaylist(play.party);
}

void voteOnPlaythrough(User user, Playthrough play, Vote vote) {
  bool recompute = false;
  Ballot ballot = play.ballots.firstWhere((b) => b.voter == user, orElse: () => null);

  if (ballot == null && vote != null) {
    ballot = new Ballot(user, play, vote);
    _datastore.add(ballot);
    play.ballots.add(ballot);
    recompute = true;
  }
  else if (ballot != null && ballot.vote != vote) {
    ballot.vote = vote;
    recompute = true;
  }

  /// Enforce veto condition
  if (_playthroughHitVetoCondition(play)) {
    deletePlaythrough(play);
    recompute = false;

    logger.finer('Vetoed playthrough: ${play.identity} in party: ${play.party.partyCode} due to voting conditions');
  }

  if (recompute) {
    _recomputePlaylist(play.party);
  }
}

User createUser(Party party, bool isAdmin) {
  if (!_userCanJoin(party)) {
    return null;
  }

  String name = _genValidUsername(party);
  int code = _genValidUserCode();

  User user = new User(code, party, name, isAdmin);
  _datastore.add(user);
  party.users.add(user);
  return user;
}

void deleteUser(User user) {
  _datastore.remove(user);
  user.party.users.remove(user);

  if (user.party.users.length == 0) {
    deleteParty(user.party);
    return;
  }

  user.party.transfers
      .where((t) => t.requester == user)
      .toList(growable: false)
      .forEach(deleteTransfer);

  if (user.party.player == user) {
    user.party.player = null;
  }
}


PlayerTransfer createTransfer(User user) {
  if (!_transferCreationValid(user)) {
    return null;
  }

  PlayerTransfer trans = new PlayerTransfer(user);
  _datastore.add(trans);
  user.party.transfers.add(trans);

  return trans;
}

void deleteTransfer(PlayerTransfer trans) {
  _datastore.remove(trans);
  trans.requester.party.transfers.remove(trans);
}