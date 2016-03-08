part of controllers;

/// A base class fora all concrete [RouteController]s of the server prociding
/// facilities for common behaviour and properties.
abstract class PartysharkController extends RouteController {
  /// A library private constructor since this class should only be subclassed
  /// by known clients.
  PartysharkController._();

  void _closeGoodRequest(HttpRequest req, Uri location, String body, [int status, User user]) {
    body = body ?? '{ }';

    req.response
        ..statusCode = status ?? HttpStatus.OK
        ..headers.contentType = ContentType.JSON
        ..headers.set(Header.CrossOrigin, '*')
        ..headers.set(Header.Location, location);

    if (user != null) {
      req.response.headers.set(
          Header.SetUserCode,
          user.userCode
      );
    }

    req.response
        ..write(body)
        ..close();

    logger.finer('Succesful response with body: $body');
  }

  void _closeBadRequest(HttpRequest req, _Failure fail) {
    req.response
        ..statusCode = fail.status
        ..headers.contentType = ContentType.JSON
        ..headers.set(Header.CrossOrigin, '*')
        ..write(fail.toJsonString())
        ..close();

    logger.fine('Failed response: ${fail.toJsonString()}');
  }

  /// Retrieves entities and validates a request according to the requirements
  /// specified as named parameters. If the request does not meet the requirements
  /// in some way, it will be closed and the [_Preperation] will be marked
  /// with [hasError].
  Future<_Preperation> _prepareRequest(HttpRequest req, Map<RouteKey, String> pathParams,
    {Jsonable getBodyAs: null, bool getParty: true, bool getRequester: true, bool checkRequesterAdmin: true}
  ) async {
    _Preperation prep = new _Preperation();

    logger.finer('Preparing request with params: $pathParams');

    Future<_Failure> getFail() async {
      if(getBodyAs != null) {
        var x = await __getBody(req, getBodyAs);
        if (x is _Failure) { return x; }
        prep.body = x;
      }

      if(getParty) {
        var x =  __getParty(pathParams[Key.PartyCode], req);
        if(x is _Failure) { return x; }
        else { prep.party = x; }
      }

      if(getRequester) {
        var x = __getRequester(req);
        if(x is _Failure) { return x; }
        else  { prep.requester = x; }

        x = __isMember(prep.party, prep.requester);
        if(x is _Failure) { return x; }

        if(checkRequesterAdmin) {
          var x = __requesterIsAdmin(prep.requester);
          if(x is _Failure) { return x; }
        }
      }

      return null;
    }

    _Failure fail = await getFail();
    if(fail != null) {
      _closeBadRequest(req, fail);
      prep.hadError = true;
    }
    else {
      prep.hadError = false;
    }

    logger.finer('Pequest prepared');

    return prep;
  }

  /// Returns the [Party] in [datastore] associated with the provided numeric
  /// [String]. If the [Party] does not exist, or some other problem is
  /// encountered, a [_Failure] is returned instead.
  dynamic __getParty(String partyCodeString, HttpRequest req) {
    Party ret;

    String getErr(){
      int partyCode = int.parse(partyCodeString, onError: (s) => null);
      logger.finest('Request for party: $partyCode');

      if(partyCode == null) {
        return 'The party code was malformed.';
      }

      ret = datastore.parties[partyCode];
      if(ret == null) {
        return 'The party code does not match a current party.';
      }

      return null;
    }

    String why = getErr();
    return (why == null) ? ret
      : new _Failure(HttpStatus.NOT_FOUND, 'The requested party does not exist.', why);
  }

  /// Returns the [User] in [datastore] associated with the user code header in
  /// [req]. If the [User] does not exist, or some other problem is
  /// encountered, a [_Failure] is returned instead.
  dynamic __getRequester(HttpRequest req) {
    User ret;

    String getWhy() {
      String userCodeString = req.headers.value(Header.UserCode);
      logger.finest('Request had ${Header.UserCode}: $userCodeString');

      if(userCodeString == null) {
        return 'The request did not carry a ${Header.UserCode} header.';
      }

      int userCode = int.parse(userCodeString, onError: (s) => null);
      if(userCode == null) {
        return 'The user code in ${Header.UserCode} was malformed.';
      }

      ret = datastore.users[userCode];
      if(ret == null) {
        return 'The user specified by ${Header.UserCode} does not exist.';
      }

      return null;
    }

    String why = getWhy();
    return (why == null) ? ret
        : new _Failure(HttpStatus.NOT_FOUND, 'The requested party does not exist.', why);
  }

  /// Asynchronously retrieves the body of an [HttpRequest] and fills a supplied
  /// [Jsonable].
  dynamic __getBody(HttpRequest req, Jsonable msg) async {
    try {
      String json = await UTF8.decodeStream(req);
      msg.fillFromJsonString(json);

      logger.finest('Request had valid body: $json');

      return msg;
    }
    on Exception catch (e) {
      return new _Failure(
          HttpStatus.BAD_REQUEST,
          'The request body could not be interpreted',
          e.toString()
      );
    }
  }

  /// Checks whether [user] is a member of [party]. If so, null is returned;
  /// if not, a [_Failure] is returned instead.
  _Failure __isMember(Party party, User user) {
    if (party?.users?.contains(user) == true) {
      logger.finest('Requesting user verified as party member');
      return null;
    }
    else {
      return new _Failure(
          HttpStatus.BAD_REQUEST,
          'This user must be a member of the party and is not.',
          'The specifed user and party exist but are not related.'
      );
    }
  }

  /// Checks whether [user] is an administrator at their party. If so, null
  /// is returned; if not, a [_Failure] is returned instead.
  _Failure __requesterIsAdmin(User user) {
    if (user?.isAdmin == true) {
      logger.finest('Requesting user verified as administrator');
      return null;
    }
    else {
      return new _Failure(
          HttpStatus.BAD_REQUEST,
          'This user is not an administrator.',
          'The specifed user and party exist but are not related.'
      );
    }
  }
}