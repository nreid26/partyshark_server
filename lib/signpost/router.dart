part of signpost;

///A class that can accept HttpRequests can route them to RouteControllers base on a provided definition
class Router implements Function {
  //Data
  final _Route _root;

  //Constructor
  Router(MisrouteController controller, Map definition) : _root = new _Route(null, null, controller) {
    if(controller == null) { throw new ArgumentError.notNull('controller'); }
    controller.setPathSegments([]);
    _translateDefinition(definition);
  }

  //Methods
  void call(HttpRequest req) { routeRequest(req); }

  void routeRequest(HttpRequest req) {
    Iterator<String> segmentItr = req.uri.pathSegments.iterator;
    Map<PathParameterKey, String> pathParams = {};
    _Route route = _root;
    bool misroute = false;

    traversal: while(segmentItr.moveNext() && !misroute) { //For each path segment
      bool segMatch = false;

      for (_Route subroute in route._subroutes) { //For each subroute
        if (subroute._segment is PathParameterKey) {
          pathParams[subroute._segment] = segmentItr.current;
          segMatch = true;
        }
        segMatch = segMatch || (subroute._segment == segmentItr.current);

        if(segMatch) {
          route = subroute;
          continue traversal;
        }
      }

      misroute = true; //If no matching subroute (or no subroutes at all)
    }

    //Final route must have controller
    if(route._controller == null) { misroute = true; }

    if(misroute) {
      while(route._controller is! MisrouteController) { route = route._parent; }
      (route._controller as MisrouteController).handleUnroutableRequest(pathParams, req);
    }
    else { route._controller.distributeByMethod(pathParams, req); }
  }

  void _translateDefinition(Map definition) {
    List<_Route> routePath = [_root];

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
          try {
            con?.setPathSegments(routePath.map((r) => r._segment).skip(1));
          } catch(e) {
            throw new RouterDefinitionError('Found a duplicate $RouteController in $Router definition; ${RouteController}s must be unique');
          }
          extractRecursive(subs);
        routePath.removeLast();
      });
    }

    extractRecursive(definition);
  }
}
