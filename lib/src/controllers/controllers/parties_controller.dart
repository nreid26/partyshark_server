part of controllers;

class PartiesController extends PartysharkController {
  PartiesController._(): super._();

  /// Create a party.
  @HttpHandler(HttpMethod.Post)
  void post(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) {
    SettingsGroup settings = new SettingsGroup();
    Party party = new Party(rand_serve.adminCode, settings);
    User user = new User(party, rand_serve.username, true);

    user.identity = rand_serve.usercode;

    model
      ..add(settings)
      ..add(party)
      ..add(user);

    var partyMsg = new PartyMsg()
      ..adminCode.value = party.adminCode
      ..code.value = party.identity
      ..isPlaying.value = party.isPlaying
      ..player.value = user.username;

    Uri location = partyController.recoverUri({CustomKey.PartyCode: party.identity});
    _closeGoodRequest(req, location, partyMsg, null, user);
  }
}