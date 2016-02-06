part of signpost;

/// A class that can accept [HttpRequest]s can route them to [RouteController]s
/// based on a provided definition.
class Router {
  //Data
  final _Route _root;

  /// The base of all URIs this [Router] is intended to route to.
  final Uri baseUri;

  /// The default generative constructor of a [Router]. [hostUri] should be a
  /// a [String] representation of the scheme and host that this [Router] is
  /// using as its public face. [definition] should be nested [Map]s with
  /// [String] or [ParameterPathKey] keys describing the routing tree and values
  /// which are the associated [RouteController]; for routes with both a
  /// controller and subroutes, a [List] containing the [RouteController]
  /// followed by the subroute [Map] should be used as the value.
  Router(String baseUri, MisrouteController controller, Map definition)
      : _root = new _Route(null, null, controller), baseUri = Uri.parse(baseUri)
  {
    if(controller == null) { throw new ArgumentError.notNull('controller'); }
    _translateDefinition(definition);
  }

  /// Traverses the routing tree according to the path of [req.uri]
  /// and dispatches the request to the associated [RouteController].
  /// If the route does not exist, the tree is traversed upwards until the first
  /// [MisrouteController] is found.
  Future routeRequest(HttpRequest req) async {
    Map<PathParameterKey, String> pathParams = {};
    _Route route = _root;
    bool routeMissing = false;

    traversal: for(String seg in req.uri.pathSegments) {
      bool segMatch = false;

      for (_Route subroute in route._subroutes) { //For each subroute
        if (subroute._segment is PathParameterKey) {
          pathParams[subroute._segment] = seg;
          segMatch = true;
        }
        else if (subroute._segment == seg) { segMatch = true; };

        if (segMatch) {
          route = subroute;
          continue traversal;
        }
      }

      routeMissing = true; //If no matching subroute (or no subroutes at all)
      break traversal;
    }

    try {
      var potFuture;

      if (routeMissing || route._controller == null) { //Routing failed or final route has no controller
        while(route._controller is! MisrouteController) { route = route._parent; }
        potFuture = (route._controller as MisrouteController).handleUnroutableRequest(req, pathParams);
      }
      else { //Route found
        potFuture = route._controller._distributeByMethod(req, pathParams);
      }

      if (potFuture is Future) { await potFuture; }
    }
    on Exception catch (e) {
      try { handleInternalException(req, e); }
      on Exception { }
      rethrow;
    }
    finally {
      req.response.close();
    }
  }

  /// Receives any [Exception] thrown by a method in a [RouteController] marked
  /// with [HttpHandler] as well as the [HttpRequest] caused it. [e] is
  /// always asynchronously rethrown but this method provides a chance to do
  /// logging or attempt an error response.
  void handleInternalException(HttpRequest req, Exception e) {
    req.response
      ..statusCode = HttpStatus.INTERNAL_SERVER_ERROR
      ..headers.contentType = ContentType.JSON
      ..write(errorJson(
          'The server could not handle this request.',
          'The code to handle this request is buggy.'
      ))
      ..close();
  }

  void _translateDefinition(Map definition) {
    List<_Route> routePath = [_root];

    _root._controller
      .._router = this
      .._pathSegments = [];

    void extractRecursive(Map subDef) {
      if(subDef == null) { return; }

      subDef.forEach((segment, right) { //For each route in the subdefinition
        RouteController con;
        Map subs;

        //Segment
        if(segment is String) { }
        else if(segment is PathParameterKey) {
          if(routePath.map((r) => r._segment).contains(segment)) { //Ensure keys are unique
            throw new RouterDefinitionError('Found duplicate $PathParameterKey in path in $Router definition; ${PathParameterKey}s must be unique in a path');
          }
        }
        else { throw new RouterDefinitionError('Found $segment as segment in $Router definition; expected a $String or $PathParameterKey'); }

        //Argument extraction
        if(right is RouteController) { con = right; }
        else if(right is Map) { subs = right; }
        else if(right is List && right.length == 2) {
          if(right[0] is RouteController) { con = right[0]; }
          else { throw new RouterDefinitionError('Found ${right[0]} at position 0 in $List in $Router definition; expected a $RouteController'); }

          if(right[1] is Map) { subs = right[1]; }
          else { throw new RouterDefinitionError('Found ${right[1]} at position 1 in $List in $Router definition; expected a $Map'); }
        }
        else { throw new RouterDefinitionError('Found ${right.runtimeType} in $Router definition; expected $RouteController, $Map, or $List[2]'); }

        //Validity test
        if(con == null && (subs == null || subs.isEmpty)) {
          throw new RouterDefinitionError('Found a leaf route in $Router definition with no $RouteController; route has no purpose');
        }

        //Recursion
        _Route built = new _Route(routePath.last, segment, con);
        routePath.add(built);

        if(con != null) {
          con
            .._router = this
            .._pathSegments = routePath.map((r) => r._segment).skip(1);
        }
        extractRecursive(subs);

        routePath.removeLast();
      });
    }

    extractRecursive(definition);
  }
}
