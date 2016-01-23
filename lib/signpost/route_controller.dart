part of signpost;

///A class implementing the basic behaviour required to respond to an HttpRequest
abstract class RouteController {
  //Statics
  static String buildErrorJson(String what, String why) =>
      '{"what":${JSON.encode(what)},"why":${JSON.encode(why)}}';

  static handleDefault(HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.METHOD_NOT_ALLOWED
      ..headers.contentType = ContentType.JSON
      ..write(buildErrorJson(
          'The request could not be handled',
          'The requested rousource exists but does not suppost the requested method'
      ))
      ..close();
  }

  //Data
  List _pathSegments;

  //Methods
  String buildPathFromArguments(Map<PathParameterKey, String> args) =>
    (_pathSegments == null)
      ? ''
      : '/' + _pathSegments.map((seg) => (args.containsKey(seg)) ? args[seg] : seg).join('/');

  void distributeByMethod(Map<PathParameterKey, String> pathParams, HttpRequest req) {
    String key = req.method.toUpperCase();

    if(key == 'CONNECT') { connect(pathParams, req); }
    else if(key == 'DELETE') { delete(pathParams, req); }
    else if(key == 'GET') { get(pathParams, req); }
    else if(key == 'HEAD') { get(pathParams, req); }
    else if(key == 'OPTIONS') { options(pathParams, req); }
    else if(key == 'PATCH') { options(pathParams, req); }
    else if(key == 'POST') { post(pathParams, req); }
    else if(key == 'PUT') { put(pathParams, req); }
    else if(key == 'TRACE') { options(pathParams, req); }
    else { handleDefault(req); }
  }

  void connect(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void delete(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void get(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void head(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void options(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void patch(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void post(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void put(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void trace(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
}

///A class implementing the behaviour of a RouteController but also able to handle unroutable requests
abstract class MisrouteController extends RouteController {
  //Methods
  void handleUnroutableRequest(Map<PathParameterKey, String> pathParams, HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.NOT_FOUND
      ..headers.contentType = ContentType.JSON
      ..write(RouteController.builfErrorJson(
        'The requested resource could not be found',
        'The requested resource does not exsit'
      ))
      ..close();
  }
}