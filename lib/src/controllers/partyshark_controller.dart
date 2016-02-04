part of controllers;

/// A base class fora all concrete [RouteController]s of the server prociding
/// facilities for common behaviour and properties.
abstract class PartysharkController extends RouteController {
  //Data
  Datastore model;

  /// Returns the [Party] in [model] associated with the provided numeric
  /// [String]. If the [Party] does not exist, or some other problem is
  /// encountered, [req] is closed with error and [null] is returned.
  Party getParty(String partyCodeString, HttpRequest req) {
    Party ret;

    String err = ((){
      int partyCode = int.parse(partyCodeString, onError: (s) {
        return 'The party code was malformed.';
      });

      ret = model[Party][partyCode];
      if(ret == null) {
        return 'The party code does not match a current party.';
      }
    })();

    if(err != null) {
      req.response
        ..statusCode = HttpStatus.NOT_FOUND
        ..headers.contentType = ContentType.JSON
        ..write(errorJson('The requested party does not exist.', err))
        ..close();
    }

    return ret;
  }

  /// Returns the [User] in [model] associated with the user code header in
  /// [req]. If the [User] does not exist, or some other problem is
  /// encountered, [req] is closed with error and [null] is returned.
  User getUserFromHeader(HttpRequest req) {
    User ret;

    String err = (() {
      String userCode64 = req.response.headers.value(_CustomHeader.UserCode);
      if(userCode64 == null) {
        return 'The request did not carry a ${_CustomHeader.UserCode} header.';
      }

      int useCode = decodeBase64(userCode64);
      if(useCode == null) {
        return 'The user code in ${_CustomHeader.UserCode} was malformed Base64.';
      }

      ret = model[User][useCode];
      if(ret == null) {
        return 'The user specified by ${_CustomHeader.UserCode} does not exist.';
      }
    })();

    if(err != null) {
      req.response
        ..statusCode = HttpStatus.BAD_REQUEST
        ..headers.contentType = ContentType.JSON
        ..write(errorJson('You are not registerd as a user.', err))
        ..close();
    }

    return ret;
  }

  /// Checks whether [user] is a member of [party]. If so, true is returned;
  /// if not, [req] is closed with error and false is returned.
  bool isMember(Party party, User user, HttpRequest req) {
    bool member = party?.users?.contains(user) ?? false;

    if(!member) {
      req.response
        ..statusCode = HttpStatus.BAD_REQUEST
        ..headers.contentType = ContentType.JSON
        ..write(errorJson(
            'This user must be a member of the party and is not.',
            'The specifed user and party exist but are not related.'
        ))
        ..close();
    }

    return member;
  }

  /// Checks whether [user] is an administrator at their party. If so, true
  /// is returned; if not, [req] is closed with error and false is returned.
  bool isAdmin(User user, HttpRequest req) {
    if(!user?.isAdmin ?? false) {
      req.response
        ..statusCode = HttpStatus.BAD_REQUEST
        ..headers.contentType = ContentType.JSON
        ..write(errorJson(
            'This user is not an administrator.',
            'The specifed user and party exist but are not related.'))
        ..close();
    }

    return user?.isAdmin;
  }
}