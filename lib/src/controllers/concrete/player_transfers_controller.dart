part of controllers;

class PlayerTransfersController extends PartysharkController with PlayerTransferMessenger {
  PlayerTransfersController._(): super._();

  /// Handle CORS preflight.
  @HttpHandler(HttpMethod.Options)
  void options(HttpRequest req, Map<RouteKey, String> pathParams) {
    super.options(req, pathParams);
  }

  /// Get all transfers in the party.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, Map<RouteKey, String> pathParams) async {
    model.logger.fine('Serving ${HttpMethod.Get} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    Iterable<UserMsg> msgs = prep.party.transfers.map(transferToMsg);
    _closeGoodRequest(req, recoverUri(pathParams), msgs);
  }

  /// Create a user.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, Map<RouteKey, String> pathParams) async {
    model.logger.fine('Serving ${HttpMethod.Post} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new PlayerTransferMsg(), checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = prep.body as PlayerTransferMsg;

    PlayerTransfer trans = model.createTransfer(prep.requester);
    if (trans == null) {
      const String what = 'Your request to be player was pre-emptively rejected.';
      const String why = 'Your request violated party settings.';
      _closeBadRequest(req, new _Failure(HttpStatus.BAD_REQUEST, what, why));
      return;
    }

    msg = transferToMsg(trans);
    Uri location = Controller.Transfer.recoverUri({Key.PartyCode: prep.party.partyCode, Key.Username: trans.identity});
    _closeGoodRequest(req, location, msg);
  }
}