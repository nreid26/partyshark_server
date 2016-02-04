part of signpost;

/// A class implementing the basic behaviour required to respond to an
/// [HttpRequest]. Designed to integrate with a [Router] and automatically
/// generate as much functionally dependent behaviour as possible.
abstract class RouteController {
  //Data
  List __pathSegments;
  Uri _constantUri;
  Map<String, Symbol> _methodMap = { };
  Router _router;
  String _supportedMethodsString;
  InstanceMirror _reflection;

  /// The default generative constructor of all [RouteController]s.
  RouteController() {
    _reflection = reflect(this);

    void searchMirror(ClassMirror cm) {
      cm.declarations.forEach((Symbol s, DeclarationMirror d) {
        d.metadata
            .map((InstanceMirror i) => i.reflectee)
            .where((dynamic r) => r is HttpHandler)
            .forEach((HttpHandler h) => _methodMap[h.methodName] = s);
      });
    }

    [RouteController, this.runtimeType]
        .map(reflectClass)
        .forEach(searchMirror);

    if(_methodMap.containsKey(HttpMethod.Get) && !_methodMap.containsKey(HttpMethod.Head)) {
      _methodMap[HttpMethod.Head] = _methodMap[HttpMethod.Get];
    }

    _supportedMethodsString = (_methodMap.keys.toList()..sort()).join(',');
  }

  //Set the path segments of the route leading to this controller and perform
  // some member updating.
  void set _pathSegments(Iterable segments) {
    if(segments.every((segment) => segment is String)) {
      _constantUri = _router._baseUri.replace(pathSegments: segments);
    }
    else {
      __pathSegments = segments.toList(growable: false);
    }
  }

  /// Recovers the [Uri] leading to this controller with
  /// [PathParameterKey]s substituted for mapped values. If required values
  /// are missing this method throws an [ArgumentError].
  Uri recoverUri([Map<PathParameterKey, dynamic> pathParams]) {
    return _constantUri ??
      _router._baseUri.replace(
          pathSegments: __pathSegments.map((s) {
            if(s is String) { return s; }
            else {
              if(pathParams.containsKey(s)) { return pathParams[s].toString(); }
              else { throw new ArgumentError('At least one necessary path parameter was missing'); }
            }
          })
      );
  }

  void _distributeByMethod(HttpRequest req, Map<PathParameterKey, String> pathParams) {
    String key = req.method.toUpperCase();

    if(_methodMap.containsKey(key)) {
      _reflection.invoke(_methodMap[key], [req, pathParams]);
    }
    else {
      handleUnsupportedMethod(req, pathParams);
    }
  }

  /// Handle requests routed to this [RouteController] which have a method that
  /// is not supported.
  void handleUnsupportedMethod(HttpRequest req, Map<PathParameterKey, String> pathParams) {
    req.response
      ..statusCode = HttpStatus.METHOD_NOT_ALLOWED
      ..headers.contentType = ContentType.JSON
      ..headers.set('Allow', _supportedMethodsString)
      ..write(errorJson(
          'The request could not be handled.',
          'The requested rousource exists but does not suppost the requested method.'
      ))
      ..close();
  }

  @HttpHandler(HttpMethod.Options)
  void _options(HttpRequest req, Map<PathParameterKey, String> pathParams) {
    req.response
      ..statusCode = HttpStatus.OK
      ..headers.set('Allow', _supportedMethodsString)
      ..close();
  }
}

/// A class extended to handle unroutable [HttpRequest]s designating non-existent/functional
/// routes. When such a request is received, the routing tree is
/// traversed upwards from the specified route until the first
/// [MisrouteController] is found; the behaviour of that instance is then
/// invoked.
abstract class MisrouteController extends RouteController {

  /// This method is called when this [MisrouteController] is selected to handle
  /// a request that had no existing route.
  void handleUnroutableRequest(HttpRequest req, [Map<PathParameterKey, String> pathParams]) {
    req.response
      ..statusCode = HttpStatus.NOT_FOUND
      ..headers.contentType = ContentType.JSON
      ..write(errorJson(
        'The requested resource could not be found',
        'The requested resource does not exsit'
      ))
      ..close();
  }
}