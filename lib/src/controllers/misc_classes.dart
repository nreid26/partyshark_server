part of controllers;

/// A namespace class defining [String] constants naming HTTP headers
/// used by this library.
class CustomHeader {
  static const String
      SetUserCode = 'X-Set-User-Code',
      UserCode = 'X-User-Code',
      Location = 'Location',
      CrossOrigin = 'Access-Control-Allow-Origin';

  CustomHeader.__();
}

/// A namespace class defining [RouteKey] constants used by this library.
class CustomKey {
  static final RouteKey
      PartyCode = new RouteKey(),
      Username = new RouteKey(),
      PlaythroughCode = new RouteKey(),
      TransferRequestCode = new RouteKey(),
      SongCode = new RouteKey();

  CustomKey.__();
}

/// A message class holding data from successful precomputations.
class _Preperation {
  User requester, user;
  Party party;
  Map<String, dynamic> body;

  bool hadError = true;
}

/// A message class holding data needed to generate a failed HTTP response.
class _Failure {
  int status;
  String what, why;

  String toJsonString() => errorJson(what, why);

  _Failure(this.status, this.what, this.why);
}