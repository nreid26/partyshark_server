part of controllers;

class PartyController extends PartysharkController {
  PartyController._(): super._();

  /// Update a party.
  @HttpHandler(HttpMethod.Put)
  Future put(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams);
    if (prep.hadError) { return; }

    var partyMsg = new PartyMsg()..fillFromJsonMap(prep.body);
    if(partyMsg.isPlaying.isDefined) {
      prep.party.isPlaying = partyMsg.isPlaying.value;
    }

    __respondWithParty(req, pathParams, prep);
  }

  /// Get a party.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBody: false, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    __respondWithParty(req, pathParams, prep);
  }

  void __respondWithParty(HttpRequest req, Map pathParams, _Preperation prep) {
    var partyMsg = new PartyMsg()
      ..adminCode.value = prep.party.adminCode
      ..adminCode.isDefined = prep.requester.isAdmin
      ..code.value = prep.party.identity
      ..isPlaying.value = prep.party.isPlaying
      ..player.value = prep.party.player.username;


    _closeGoodRequest(req, recoverUri({CustomKey.PartyCode: prep.party.identity}), partyMsg.toJsonString());
  }
}