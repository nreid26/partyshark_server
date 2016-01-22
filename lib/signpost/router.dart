part of signpost;

///A class that can accept HttpRequests can route them to RouteControllers base on a provided definition
class Router {
  //Data
  final _Route _root;

  //Constructor
  Router(MisrouteController controller, Map<Pattern, dynamic> definition) : _root = new _Route(null, null, controller, definition) {
    if(controller == null) { throw new ArgumentError.notNull('controller'); }
  }

  //Methods
  void routeRequest(HttpRequest req) {
    Iterator<String> segmentItr = req.uri.pathSegments.iterator;
    List<String> pathParams = [];
    _Route route = _root;

    bool misroute = false;

    traversal: while(segmentItr.moveNext() && !misroute) { //For each path segment
      for (_Route subroute in route._subroutes) { //For each subroute
        if (subroute._segment == null) {
          pathParams.add(segmentItr.current);
          route = subroute;
          continue traversal;
        }
        else if (subroute._segment == segmentItr.current) {
          route = subroute;
          continue traversal;
        }
      }

      //If no matching subroute (or no subroutes at all)
      misroute = true;
    }

    //Final route must have controller
    if(route._controller == null) { misroute = true; }

    if(misroute) {
      while(route._controller is! MisrouteController) {
        route = route._parent;
      }
      //Handle misrouted request
    }
    else {

    }
  }
}