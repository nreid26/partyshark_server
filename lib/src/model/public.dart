part of model;

Party createParty() {
  /// Make and store new objects
  SettingsGroup settings = new SettingsGroup();
  _datastore.add(settings);

  Party party = new Party(rand_serve.adminCode, settings);
  _datastore.add(party);

  User user = new User(_genValidUserCode(), party, rand_serve.username, true);
  _datastore.add(user);

  /// Link new object
  party
        ..users.add(user)
        ..player = user;
  settings.party = party;

  logger
      ..fine('Created new party: ${party.partyCode}')
      ..fine('Created new user: ${user.userCode}');

  return party;
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

    logger.finer('Vetoed playthrough: ${play.identity} in party: ${prep.party.partyCode} due to voting conditions');
  }

  if (recompute) {
    _recomputePlalist(play.party);
  }
}