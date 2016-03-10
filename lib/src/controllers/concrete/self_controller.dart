part of controllers;

class SelfController extends PartysharkController {
  SelfController._() : super._();

  /// Get yourself.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = Controller.User._userToMsg(prep.requester);

    _closeGoodRequest(req, recoverUri(pathParams), msg.toJsonString());

    model.logger.fine('Served user: ${prep.requester.userCode} to self');
  }

  /// Update yourself.
  @HttpHandler(HttpMethod.Put)
  Future put(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new UserMsg(), checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = prep.body as UserMsg;

    if (msg.adminCode.isDefined && msg.adminCode.value == prep.party.adminCode) {
      prep.requester.isAdmin = true;
    }

    String resString = Controller.User._userToMsg(prep.requester).toJsonString();
    _closeGoodRequest(req, recoverUri(pathParams), resString, null, prep.requester);

    model.logger.fine('Updated user: ${prep.requester.userCode}');
  }

  /// Leave the party.
  @HttpHandler(HttpMethod.Delete)
  Future delete(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    datastore.users.remove(prep.requester);

    prep.party
        ..users.remove(prep.requester)
        ..player = null;

    /// TODO: Clean up party if empty
    /// will share code with cleanup service

    model.logger.fine('Updated user: ${prep.requester.userCode}');
  }
}