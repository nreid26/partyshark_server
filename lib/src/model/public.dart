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

  Playthrough play = new Playthrough(song, party.playthroughs.length, suggester);
  Ballot ballot = new Ballot(suggester, play, Vote.Up);

  _datastore
    ..add(play)
    ..add(ballot);

  return play
    ..party.playthroughs.add(play)
    ..ballots.add(ballot);
}

Future<Song> getSong(int songCode) async {
    Song song = _datastore[Song][songCode];

    if (song == null) {
      logger.finer('Queried Deezer for song: $songCode');
      song = await deezer.getSong(songCode);

      if (song != null) { _datastore.add(song); }
    }

    return song;
}

dynamic getEntity(Type type, int identity) {
  Table table = _datastore[type];
  return (table == null) ? null : table[identity];
}

void modifyEntity(entity, void modify()) {
  const Map<Type, Function> handlers = const {
    Party: null,
    Playthrough: null,
    Ballot: null,
    PlayerTransfer: null,
    SettingsGroup: null,
    User: null
  };

  Function handler = handlers[entity.runtimeType];
  if (handler != null) { handler(entity, modify); }
  else { modify(); }
}