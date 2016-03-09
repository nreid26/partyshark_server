part of controllers;

class UsersController extends PartysharkController {
  UsersController._(): super._();

  /// Get all users in the party.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    Iterable<UserMsg> msgs = prep.party.users.map(Controller.User._userToMsg);
    _closeGoodRequest(req, recoverUri(pathParams), toJsonGroupString(msgs));

    logger.fine('Served users for party: ${prep.party.partyCode}');
  }

  /// Create a user.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new UserMsg(), getRequester: false, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    if (!__userCanJoin(req, prep)) { return; }

    var msg = prep.body as UserMsg;

    /// Generate new objects
    User user = new User(_genValidUserCode(), prep.party, __genValidUsername(prep.party), msg.adminCode.isDefined && msg.adminCode.value == prep.party.adminCode);
    datastore.add(user);

    /// Link new objects
    prep.party.users.add(user); // MUST HAPPEN AFTER STORE INSERTION

    /// Make response
    msg = Controller.User._userToMsg(user);

    //TODO: Recover Location from other controller
    _closeGoodRequest(req, null, msg.toJsonString(), null, user);

    logger.fine('Created new user: ${user.userCode}');
  }

  int _genValidUserCode() {
    int u = rand_serve.userCode;
    while (datastore.users.containsIdentity(u)) { u++; }
    return u;
  }

  String __genValidUsername(Party party) {
    String username;
    int maxAttempts = 10;
    Set<String> takenNames = party.users.map((u) => u.username).toSet();

    do {
      username = rand_serve.username;
      maxAttempts--;
    } while (maxAttempts > 0 && takenNames.contains(username));

    if (maxAttempts == 0) { throw new Exception('Could not generate a unique username for party: ${party.partyCode}'); }
    return username;
  }

  bool __userCanJoin(HttpRequest req, _Preperation prep) {
    if (prep.party.settings.userCap == null) { return true; }

    if (prep.party.users.length < prep.party.settings.userCap) { return true; }
    else {
      _closeBadRequest(req, new _Failure(HttpStatus.BAD_REQUEST, 'You could not join the party.', 'The party you attempted to join is full.'));
      return false;
    }
  }

}