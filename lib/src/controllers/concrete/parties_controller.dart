part of controllers;

class PartiesController extends PartysharkController {
  PartiesController._(): super._();

  /// Create a party.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    model.logger.fine('Serving ${HttpMethod.Post} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, getRequester: false, getBodyAs: EmptyMsg.only, getParty: false);
    if (prep.hadError) { return; }

    Party party = model.createParty();
    User user = party.users.first;

    var msg = new PartyMsg()
      ..code.value = party.partyCode
      ..adminCode.value = party.adminCode
      ..code.value = party.identity
      ..isPlaying.value = party.isPlaying
      ..player.value = user.username;

    Uri location = Controller.Party.recoverUri({Key.PartyCode: party.partyCode});
    _closeGoodRequest(req, location, msg, null, user);
  }
}