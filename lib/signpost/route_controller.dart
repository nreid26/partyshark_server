part of signpost;

abstract class RouteController {
  //Statics
  static _defaultHandle(HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.METHOD_NOT_ALLOWED
      ..headers.contentType = ContentType.JSON
      ..write({
        'what': 'The request could not be handled',
        'why': 'The requested rousource exists but does not suppost the requested method'
      })
      ..close();
  }

  //Methods
  void distributeByMethod(List<String> pathParams, HttpRequest req) {
    String key = req.method.toUpperCase();

    if(key == 'DELETE') { delete(pathParams, req); }
    else if(key == 'GET') { get(pathParams, req); }
    else if(key == 'POST') { post(pathParams, req); }
    else if(key == 'PUT') { put(pathParams, req); }
    else if(key == 'OPTIONS') { options(pathParams, req); }
    else { _defaultHandle(req); }
  }
  
  void delete(List<String> pathParams, HttpRequest req) { _defaultHandle(req); }
  void get(List<String> pathParams, HttpRequest req) { _defaultHandle(req); }
  void put(List<String> pathParams, HttpRequest req) { _defaultHandle(req); }
  void post(List<String> pathParams, HttpRequest req) { _defaultHandle(req); }
  void options(List<String> pathParams, HttpRequest req) { _defaultHandle(req); }
}

abstract class MisrouteController extends RouteController {
  //Methods
  void handleUnroutableRequest(List<String> pathParams, HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.NOT_FOUND
      ..headers.contentType = ContentType.JSON
      ..write({
        'what': 'The requested resource could not be found',
        'why': 'The requested resource does not exsit'
      })
      ..close();
  }
}