part of signpost;

///A class that can accept HttpRequests can route them to RouteControllers base on a provided definition
class Router {
  //Data
  final _Route _root;

  //Constructor
  Router(RouteController controller, RouteController fallback, Map<Pattern, dynamic> definition) : _root = new _Route(null, null, controller, fallback, definition);
}