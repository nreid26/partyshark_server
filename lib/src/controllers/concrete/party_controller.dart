part of controllers;

class PartyController extends PartysharkController {
  PartyController._(): super._();

  /// Get a party.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    __respondWithParty(req, pathParams, prep);

    model.logger.fine('Served party: ${prep.party.partyCode}');
  }

  /// Update a party.
  @HttpHandler(HttpMethod.Put)
  Future put(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new PartyMsg());
    if (prep.hadError) { return; }

    var msg = prep.body as PartyMsg;

    if (msg.isPlaying.isDefined && msg.isPlaying.value != null) {
      model.modifyEntity(prep.party, () {
        prep.party.isPlaying = msg.isPlaying.value;
      });
    }

    __respondWithParty(req, pathParams, prep);

    model.logger.fine('Updated party: ${prep.party.partyCode}');
  }

  void __respondWithParty(HttpRequest req, Map pathParams, _Preperation prep) {
    var msg = new PartyMsg()
      ..adminCode.value = prep.party.adminCode
      ..adminCode.isDefined = prep.requester.isAdmin
      ..code.value = prep.party.partyCode
      ..isPlaying.value = prep.party.isPlaying
      ..player.value = prep.party.player?.username;

    _closeGoodRequest(req, recoverUri(pathParams), msg);
  }
}