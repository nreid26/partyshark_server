part of signpost;

/// A class that holds the information required within a routing tree. Each
/// [_Route] is a node.
class _Route {
  final _Route _parent;
  final List<_Route> _subroutes = [];
  final dynamic _segment; //String or PathParameterKey
  final RouteController _controller;

  //Constructor
  _Route(this._parent, this._segment, this._controller) {
    if(_parent != null) { _parent._subroutes.add(this); }
  }
}
