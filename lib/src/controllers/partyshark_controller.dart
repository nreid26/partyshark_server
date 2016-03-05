part of controllers;

/// A base class fora all concrete [RouteController]s of the server prociding
/// facilities for common behaviour and properties.
abstract class PartysharkController extends RouteController {
  /// A library private constructor since this class should only be subclassed
  /// by known clients.
  PartysharkController._();

  void _closeGoodRequest(HttpRequest req, Uri location, String body, [int status, User user]) {
    req.response
        ..statusCode = status ?? HttpStatus.OK
        ..headers.contentType = ContentType.JSON
        ..headers.set(CustomHeader.CrossOrigin, '*')
        ..headers.set(CustomHeader.Location, location);

    if (user != null) {
      req.response.headers.set(
          CustomHeader.SetUserCode,
          encodeBase64(user.identity, 64)
      );
    }

    req.response
        ..write(body ?? '{ }')
        ..close();
  }

  void _closeBadRequest(HttpRequest req, _Failure fail) {
    req.response
        ..statusCode = fail.status
        ..headers.contentType = ContentType.JSON
        ..headers.set(CustomHeader.CrossOrigin, '*')
        ..write(fail.toJsonString())
        ..close();
  }

  /// Retrieves entities and validates a request according to the requirements
  /// specified as named parameters. If the request does not meet the requirements
  /// in some way, it will be closed and the [_Preperation] will be marked
  /// with [hasError].
  Future<_Preperation> _prepareRequest(HttpRequest req, Map<RouteKey, String> pathParams,
    {bool getBody: true, bool getParty: true, bool getRequestingUser: true, bool getRequestedUser: true, bool checkRequesterAdmin: true}
  ) async {
    _Preperation prep = new _Preperation();

    Future<_Failure> getFail() async {
      if(getBody) {
        var x = await __getBody(req);
        if (x is _Failure) { return x; }
        prep.body = x;
      }

      if(getParty) {
        var x =  __getParty(pathParams[CustomKey.PartyCode], req);
        if(x is _Failure) { return x; }
        else { prep.party = x; }
      }

      if(getRequestedUser) {
        var x = __getRequestingUser(req);
        if(x is _Failure) { return x; }
        else  { prep.requester = x; }

        x = __isMember(prep.party, prep.user);
        if(x is _Failure) { return x; }
      }

      if(checkRequesterAdmin) {
        var x = __requestingUserIsAdmin(prep.requester);
        if(x is _Failure) { return x; }
      }

      return null;
    }

    _Failure fail = await getFail();
    if(fail != null) {
      _closeBadRequest(req, fail);
      prep.hadError = true;
    }

    return prep;
  }

  /// Returns the [Party] in [model] associated with the provided numeric
  /// [String]. If the [Party] does not exist, or some other problem is
  /// encountered, a [_Failure] is returned instead.
  dynamic __getParty(String partyCodeString, HttpRequest req) {
    Party ret;

    String getErr(){
      int partyCode = int.parse(partyCodeString, onError: (s) {
        return 'The party code was malformed.';
      });

      ret = model[Party][partyCode];
      if(ret == null) {
        return 'The party code does not match a current party.';
      }

      return null;
    }

    String why = getErr();
    return (why == null)
      ? ret
      : new _Failure(HttpStatus.NOT_FOUND, 'The requested party does not exist.', why);
  }

  /// Returns the [User] in [model] associated with the user code header in
  /// [req]. If the [User] does not exist, or some other problem is
  /// encountered, a [_Failure] is returned instead.
  dynamic __getRequestingUser(HttpRequest req) {
    User ret;

    String getWhy() {
      String userCode64 = req.response.headers.value(CustomHeader.UserCode);
      if(userCode64 == null) {
        return 'The request did not carry a ${CustomHeader.UserCode} header.';
      }

      int useCode = decodeBase64(userCode64);
      if(useCode == null) {
        return 'The user code in ${CustomHeader.UserCode} was malformed Base64.';
      }

      ret = model[User][useCode];
      if(ret == null) {
        return 'The user specified by ${CustomHeader.UserCode} does not exist.';
      }

      return null;
    }

    String why = getWhy();
    return (why == null)
        ? ret
        : new _Failure(HttpStatus.NOT_FOUND, 'The requested party does not exist.', why);
  }

  ///Asynchronusly retrives the body of an [HttpRequest]
  dynamic __getBody(HttpRequest req) async {
    try {
      return JSON.decode(await UTF8.decodeStream(req));
    } catch (e) {
      return new _Failure(
          HttpStatus.BAD_REQUEST,
          'The request body could not be interpreted',
          'The request body was not valid JSON'
      );
    }
  }

  /// Checks whether [user] is a member of [party]. If so, null is returned;
  /// if not, a [_Failure] is returned instead.
  _Failure __isMember(Party party, User user) =>
    (party?.users?.contains(user) ?? false)
      ? null
      : new _Failure(
          HttpStatus.BAD_REQUEST,
          'This user must be a member of the party and is not.',
          'The specifed user and party exist but are not related.'
        );

  /// Checks whether [user] is an administrator at their party. If so, null
  /// is returned; if not, a [_Failure] is returned instead.
  _Failure __requestingUserIsAdmin(User user) =>
    (user?.isAdmin ?? false)
      ? null
      : new _Failure(
          HttpStatus.BAD_REQUEST,
          'This user is not an administrator.',
          'The specifed user and party exist but are not related.'
        );
}