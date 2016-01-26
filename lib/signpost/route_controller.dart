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
  List _pathSegments = null;
  bool _pathIsConstant = true;
  List<String> get supportedMethods;

  //Constructor
  RouteController() {
    if(supportedMethods == null) {
      throw new StateError('\'supportedMethods\' must not be null; expected a const $List<$String> naming implemented HTTP methods');
    }
  }

  //Methods
  bool get pathIsConstant => _pathIsConstant;

  List<String> getPathSegments([Map<PathParameterKey, String> pathParams]) {
    String mapArgs(s) {
      if(s is String) { return s; }
      s = pathParams[s];
      if(s != null) { return s.toString(); }
      else { throw new StateError('At least one necessary path parameter was missing during path segment reconstruction'); }
    }

    if(_pathIsConstant) { return _pathSegments; }
    else if(pathParams == null) { throw new ArgumentError('Path parameter values are required to get non-constant path segments'); }
    else {
      return new UnmodifiableListView<String>(
          _pathSegments.map(mapArgs).toList(growable: false)
      );
    }
  }

  void setPathSegments(Iterable segments) {
    if(_pathSegments != null) { throw new StateError('Path segments may only be set once'); }

    _pathIsConstant = segments.every((segment) => segment is String);
    _pathSegments = segments.toList(growable: false);
    if(_pathIsConstant) { _pathSegments = new UnmodifiableListView(_pathSegments); }
  }

  void distributeByMethod(Map<PathParameterKey, String> pathParams, HttpRequest req) {
    String key = req.method.toUpperCase();

    if(key == HttpMethod.Connect) { connect(pathParams, req); }
    else if(key == HttpMethod.Delete) { delete(pathParams, req); }
    else if(key == HttpMethod.Get) { get(pathParams, req); }
    else if(key == HttpMethod.Head) { get(pathParams, req); } //Default to GET request and let client ignore body
    else if(key == HttpMethod.Options) { options(pathParams, req); }
    else if(key == HttpMethod.Patch) { patch(pathParams, req); }
    else if(key == HttpMethod.Post) { post(pathParams, req); }
    else if(key == HttpMethod.Put) { put(pathParams, req); }
    else { handleDefault(req); }
  }

  void connect(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void delete(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void get(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void head(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void patch(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void post(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }
  void put(Map<PathParameterKey, String> pathParams, HttpRequest req) { handleDefault(req); }

  void options(Map<PathParameterKey, String> pathParams, HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.OK
      ..headers.add('Allow', supportedMethods.join(', '))
      ..close();
  }

}

///A class implementing the behaviour of a RouteController but also able to handle unroutable requests
abstract class MisrouteController extends RouteController {
  //Methods
  void handleUnroutableRequest(Map<PathParameterKey, String> pathParams, HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.NOT_FOUND
      ..headers.contentType = ContentType.JSON
      ..write(RouteController.buildErrorJson(
        'The requested resource could not be found',
        'The requested resource does not exsit'
      ))
      ..close();
  }
}