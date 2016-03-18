part of controllers;

class UsersController extends PartysharkController with UserMessenger {
  UsersController._(): super._();

  /// Handle CORS preflight.
  @HttpHandler(HttpMethod.Options)
  void options(HttpRequest req, Map<RouteKey, String> pathParams) {
    super.options(req, pathParams);
  }

  /// Get all users in the party.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, Map<RouteKey, String> pathParams) async {
    model.logger.fine('Serving ${HttpMethod.Get} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    Iterable<UserMsg> msgs = prep.party.users.map(userToMsg);
    _closeGoodRequest(req, recoverUri(pathParams), msgs);
  }

  /// Create a user.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, Map<RouteKey, String> pathParams) async {
    model.logger.fine('Serving ${HttpMethod.Post} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new UserMsg(), getRequester: false, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = prep.body as UserMsg;

    User user = model.createUser(prep.party, msg.isAdmin.value);
    if (user == null) {
      const String what = 'You could not join the party.';
      const String why = 'Your request violated party settings.';
      _closeBadRequest(req, new _Failure(HttpStatus.BAD_REQUEST, what, why));
      return;
    }

    msg = userToMsg(user);
    Uri location = _parentSet.user.recoverUri({Key.PartyCode: prep.party.partyCode, Key.Username: user.username});
    _closeGoodRequest(req, location, msg, null, user);
  }





}