part of controllers;

class PartiesController extends PartysharkController {
  PartiesController._(): super._();

  /// Create a party.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getRequester: false, getBodyAs: EmptyMsg.only, getParty: false);
    if (prep.hadError) { return; }

    SettingsGroup settings = new SettingsGroup();
    datastore.add(settings);

    Party party = new Party(rand_serve.adminCode, settings);
    datastore.add(party);

    User user = new User(party, rand_serve.username, true);
    int u = rand_serve.userCode;
    while (datastore.users.containsIdentity(u)) { u++; }
    user.identity = u;
    datastore.add(user);

    // Link new objects
    party.users.add(user);
    settings.party = party;

    logger.fine('Created new party: ${party.partyCode}');
    logger.fine('Created new user: ${user.userCode}');

    var msg = new PartyMsg()
      ..code.value = party.partyCode
      ..adminCode.value = party.adminCode
      ..code.value = party.identity
      ..isPlaying.value = party.isPlaying
      ..player.value = user.username;

    Uri location = Controller.Party.recoverUri({Key.PartyCode: party.partyCode});
    _closeGoodRequest(req, location, msg.toJsonString(), null, user);
  }
}