part of controllers;

class UsersController extends PartysharkController {
  UsersController._(): super._();

  /// Get all users in the party.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    Iterable<UserMsg> msgs = prep.party.users.map(__convertToUserMsg);
    _closeGoodRequest(req, recoverUri(pathParams), toJsonGroupString(msgs));

    logger.fine('Served users for party: ${prep.party.partyCode}');
  }

  /// Create a user.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new UserMsg(), getRequester: false, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = prep.body as UserMsg;

    /// Generate username
    String username;
    do {
      username = rand_serve.username;
    } while (prep.party.users.any((u) => u.username == username));

    /// Generate new objects
    User user = new User(_genValidUserCode(), prep.party, username, msg.adminCode.isDefined && msg.adminCode.value == prep.party.adminCode);
    datastore.add(user);

    /// Link new objects
    prep.party.users.add(user); // MUST HAPPEN AFTER STORE INSERTION

    /// Make response
    msg = __convertToUserMsg(user);

    //TODO: Recover Location from other controller
    _closeGoodRequest(req, null, msg.toJsonString(), null, user);

    logger.fine('Created new user: ${user.userCode}');
  }

  UserMsg __convertToUserMsg(User user) {
    return new UserMsg()
        ..adminCode.isDefined = false
        ..username.value = user.username
        ..isAdmin.value = user.isAdmin;
  }

  int _genValidUserCode() {
    int u = rand_serve.userCode;
    while (datastore.users.containsIdentity(u)) { u++; }
    return u;
  }
}