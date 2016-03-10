part of model;

int _genValidUserCode() {
  int u = rand_serve.userCode;
  while (_datastore.users.containsIdentity(u)) { u++; }
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

bool _playthroughSuggestionValid(Song song, Party party) =>
    party.settings.playthroughCap == null || party.playthroughs.length < party.settings.playthroughCap;
