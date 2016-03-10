part of controllers;

class UserController extends PartysharkController with UserMessenger {
  UserController._(): super._();

  /// Get a user in the party.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    model.logger.fine('Serving ${HttpMethod.Get} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    String reqUsername = pathParams[Key.Username];
    Iterable<User> withName = prep.party.users.where((u) => u.username == reqUsername);

    if (withName.length == 1) {
      var msg = userToMsg(withName.first);
      _closeGoodRequest(req, recoverUri(pathParams), msg.toJsonString());

      model.logger.fine('Served user: ${prep.requester.userCode}');

      return;
    }
    else {
      const String what = 'The requested user could not be found.';
      const String why = 'The provided username was malformed of did not match a party member.';
      _closeBadRequest(req, new _Failure(HttpStatus.NOT_FOUND, what, why));

      return;
    }
  }
}