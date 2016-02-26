part of controllers;

/// A message class holding data from successful precomputations.
class _PrepMsg {
  User requestingUser, requestedUser;
  Party party;

  bool hadError = true;
}

/// A message class holding data needed to generate a failed HTTP response.
class _PrepFail {
  int status;
  String what, why;

  _PrepFail(this.status, this.what, this.why);
}

/// A base class fora all concrete [RouteController]s of the server prociding
/// facilities for common behaviour and properties.
abstract class PartysharkController extends RouteController {

  /// The model for all entities this [PartysharkController] operates on.
  Datastore model;

  /// A library private constructor since this class should only be subclassed
  /// by known clients.
  PartysharkController._();

  /// Retrieves entities and validates a request according to the requirements
  /// specified as named parameters. If the request does not meet the requirements
  /// in some way, it will be closed and the [_PrepMsg] will be marked
  /// with [hasError].
  _PrepMsg _prepareRequest(HttpRequest req, Map<RouteKey, String> pathParams, {
    bool getParty: false,
    bool getRequestingUser: false,
    bool getRequestedUser: false,
    bool checkRequestingUserIsAdmin: false
  }) {
    _PrepMsg p = new _PrepMsg();

    _PrepFail getErr() {
      var x;

      if(getParty) {
        x =  __getParty(pathParams[PathKey.PartyCode], req);
        if(x is Party) { p.party = x; }
        else { return x; }
      }

      if(getRequestedUser) {
        x = __getRequestingUser(req);
        if(x is User) { p.requestingUser = x; }
        else { return x; }

        x = __isMember(p.party, p.requestedUser);
        if(x != null){ return x; }
      }

      if(checkRequestingUserIsAdmin) {
        x = __requestingUserIsAdmin(p.requestingUser);
        if(x != null) { return x; }
      }

      return null;
    }

    _PrepFail err = getErr();
    if(err != null) {
      req.response
          ..statusCode = err.status
          ..headers.contentType = ContentType.JSON
          ..write(errorJson(err.what, err.why))
          ..close();

      p.hadError = true;
    }

    return p;
  }

  /// Returns the [Party] in [model] associated with the provided numeric
  /// [String]. If the [Party] does not exist, or some other problem is
  /// encountered, a [_PrepFail] is returned instead.
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

    String err = getErr();
    return (err == null)
      ? ret
      : new _PrepFail(
          HttpStatus.NOT_FOUND,
          'The requested party does not exist.',
          err
        );
  }

  /// Returns the [User] in [model] associated with the user code header in
  /// [req]. If the [User] does not exist, or some other problem is
  /// encountered, a [_PrepFail] is returned instead.
  dynamic __getRequestingUser(HttpRequest req) {
    User ret;

    String getErr() {
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

    String err = getErr();
    return (err == null)
        ? ret
        : new _PrepFail(
            HttpStatus.NOT_FOUND,
            'The requested party does not exist.',
            err
         );
  }

  /// Checks whether [user] is a member of [party]. If so, null is returned;
  /// if not, a [_PrepFail] is returned instead.
  _PrepFail __isMember(Party party, User user) =>
    (party?.users?.contains(user) ?? false)
      ? null
      : new _PrepFail(
          HttpStatus.BAD_REQUEST,
          'This user must be a member of the party and is not.',
          'The specifed user and party exist but are not related.'
        );

  /// Checks whether [user] is an administrator at their party. If so, null
  /// is returned; if not, a [_PrepFail] is returned instead.
  _PrepFail __requestingUserIsAdmin(User user) =>
    (user?.isAdmin ?? false)
      ? null
      : new _PrepFail(
          HttpStatus.BAD_REQUEST,
          'This user is not an administrator.',
          'The specifed user and party exist but are not related.'
        );
}