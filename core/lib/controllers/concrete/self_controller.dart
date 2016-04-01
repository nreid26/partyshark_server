part of controllers;

class SelfController extends PartysharkController with UserMessenger {
  SelfController._() : super._();

  /// Handle CORS preflight.
  @HttpHandler(HttpMethod.Options)
  void options(HttpRequest req, Map<RouteKey, String> pathParams) {
    super.options(req, pathParams);
  }

  /// Get yourself.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, Map<RouteKey, String> pathParams) async {
    model.logger.fine('Serving ${HttpMethod.Get} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = userToMsg(prep.requester);

    _closeGoodRequest(req, recoverUri(pathParams), msg.toJsonString());

  }

  /// Update yourself.
  @HttpHandler(HttpMethod.Put)
  Future put(HttpRequest req, Map<RouteKey, String> pathParams) async {
    model.logger.fine('Serving ${HttpMethod.Put} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new UserMsg(), checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = prep.body as UserMsg;

    if (msg.adminCode.isDefined) {
      prep.requester.isAdmin = msg.adminCode.value == prep.party.adminCode;
    }

    msg = userToMsg(prep.requester);
    _closeGoodRequest(req, recoverUri(pathParams), msg, null, prep.requester);
  }

  /// Leave the party.
  @HttpHandler(HttpMethod.Delete)
  Future delete(HttpRequest req, Map<RouteKey, String> pathParams) async {
    model.logger.fine('Serving ${HttpMethod.Delete} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    model.deleteUser(prep.requester);
  }
}