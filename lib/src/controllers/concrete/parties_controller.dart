part of controllers;

class PartiesController extends PartysharkController {
  PartiesController._(): super._();

  /// Create a party.
  @HttpHandler(HttpMethod.Post)
  void post(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) {
    SettingsGroup settings = new SettingsGroup();
    Party party = new Party(rand_serve.adminCode, settings);
    User user = new User(party, rand_serve.username, true);

    int u;
    do {
      u = rand_serve.usercode;
    } while (model[User].containsIdentity(u));
    user.identity = u;

    model
      ..add(settings)
      ..add(party)
      ..add(user);

    var msg = new PartyMsg()
      ..adminCode.value = party.adminCode
      ..code.value = party.identity
      ..isPlaying.value = party.isPlaying
      ..player.value = user.username;

    Uri location = Controller.Party.recoverUri({Key.PartyCode: party.identity});
    _closeGoodRequest(req, location, msg.toJsonString(), null, user);
  }
}