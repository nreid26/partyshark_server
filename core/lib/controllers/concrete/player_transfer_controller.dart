part of controllers;

class PlayerTransferController extends PartysharkController with PlayerTransferMessenger {
  PlayerTransferController._(): super._();

  /// Handle CORS preflight.
  @HttpHandler(HttpMethod.Options)
  void options(HttpRequest req, Map<RouteKey, String> pathParams) {
    super.options(req, pathParams);
  }

  /// Get a user in the party.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, Map<RouteKey, String> pathParams) async {
    model.logger.fine('Serving ${HttpMethod.Get} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    PlayerTransfer trans = __getTransfer(req, pathParams, prep.party);
    if (trans ==  null) { return; }

    _closeGoodRequest(req, recoverUri(pathParams), transferToMsg(trans));
  }

  /// Update a transfer.
  @HttpHandler(HttpMethod.Put)
  Future put(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    model.logger.fine('Serving ${HttpMethod.Put} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new PlayerTransferMsg());
    if (prep.hadError) { return; }

    var msg = prep.body as PlayerTransferMsg;

    var trans = __getTransfer(req, pathParams, prep.party);
    if (trans == null) { return; }

    /// Update status.
    if (msg.status.isDefined) {
      trans.status = msg.status.value;
    }

    _closeGoodRequest(req, recoverUri(pathParams), transferToMsg(trans));
  }

  PlayerTransfer __getTransfer(HttpRequest req, Map pathParams, Party party) {
    _Failure potFail = new _Failure(HttpStatus.NOT_FOUND, 'The transfer could not be found.', null);

    int code = int.parse(pathParams[Key.PlayerTransferCode], onError: (s) => null);
    if (code == null) {
      _closeBadRequest(req, potFail..why = 'The supplied playthrough code is malformed.');
      return null;
    }

    PlayerTransfer trans = model.getEntity(PlayerTransfer, code);
    if (trans == null || !party.transfers.contains(trans)) {
      _closeBadRequest(req, potFail..why = 'The supplied playthrough code does not exist.');
      return null;
    }

    return trans;
  }
}