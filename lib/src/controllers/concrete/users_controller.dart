part of controllers;

class UsersController extends PartysharkController {
  UsersController._(): super._();

  /// Get all users in the party.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBody: false, checkRequesterAdmin: false);
    if (prep == null) { return; }

    Iterable<UserMsg> msgs = prep.party.users.map(__convertToUserMsg);
    _closeGoodRequest(req, recoverUri(pathParams), toJsonGroupString(msgs));
  }

  /// Create a user.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getRequester: false, checkRequesterAdmin: false);
    if (prep == null) { return; }

    var msg = new UserMsg()..fillFromJsonMap(prep.body);

    // Generate user variables
    String usename;
    do {
      usename = rand_serve.username;
    } while (prep.party.users.any((u) => u.username == usename));

    bool isAdmin = msg.adminCode.isDefined && msg.adminCode.value == prep.party.adminCode;

    // Make and insert new user
    User user = new User(prep.party, usename, isAdmin);
    datastore.add(user);
    prep.party.users.add(user); // MUST HAPPEN AFTER STORE INSERTION

    // Make response
    msg = __convertToUserMsg(user);

    //TODO: Recover Location from other controller
    _closeGoodRequest(req, null, msg.toJsonString(), null, user);
  }

  UserMsg __convertToUserMsg(User user) {
    return new UserMsg()
        ..adminCode.isDefined = false
        ..username.value = user.username
        ..isAdmin.value = user.isAdmin;
  }
}