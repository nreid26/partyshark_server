part of controllers;

/// A namespace class defining [String] constants naming HTTP headers
/// used by this library.
class Header {
  static const String
      SetUserCode = 'X-Set-User-Code',
      UserCode = 'X-User-Code',
      Location = 'Location',
      CorsExposeHeaders = 'Access-Control-Expose-Headers',
      CorsAllowOrigin = 'Access-Control-Allow-Origin',
      CorsAllowHeaders = 'Access-Control-Allow-Headers',
      CorsAllowMethods = 'Access-Control-Allow-Methods',
      CorsRequestHeaders = 'Access-Control-Request-Headers';

  Header.__();
}

/// A message class holding data from successful precomputations.
class _Preperation {
  User requester;
  Party party;
  Jsonable body;

  bool hadError;
}

/// A message class holding data needed to generate a failed HTTP response.
class _Failure {
  int status;
  String what, why;

  String toJsonString() => errorJson(what, why);

  _Failure(this.status, this.what, this.why);
}