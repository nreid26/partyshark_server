part of signpost;

class _Route {
  //Statics
  static final RegExp _braced = new RegExp(r'^{.*}$');

  static _Route _mapDefinition(_Route parent, String segment, dynamic definition) {
    RouteController con;
    Map<Pattern, dynamic> subs;

    //Pattern
    if(segment is String) {
      if(_braced.hasMatch(segment)) { segment = null; }
    }
    else { throw new ArgumentError('Found $segment as segment in $Router definition; expected a $String'); }

    //Argument extraction
    if(definition is RouteController) { con = definition; }
    else if(definition is Map) { subs = definition; }
    else if(definition is List && definition.length == 2) {
      if(definition[0] is RouteController) { con = definition[0]; }
      else { throw new ArgumentError('Found ${definition[0]} at position 0 in $List in $Router definition; expected a $RouteController'); }

      if(definition[1] is Map) { subs = definition[1]; }
      else { throw new ArgumentError('Found ${definition[1]} at position 1 in $List in $Router definition; expected a $Map'); }
    }
    else { throw new ArgumentError('Found ${definition.runtimeType} in $Router definition; expected $RouteController, $Map, or $List[2]'); }

    //Recursion
    return new _Route(parent, segment, con, subs);
  }

  //Data
  final _Route _parent;
  final List<_Route> _subroutes = [];
  final String _segment;
  final RouteController _controller;

  //Constructor
  _Route(this._parent, this._segment, this._controller, Map<Pattern, dynamic> definition) {
    if(definition == null) { return; }

    for(String segment in definition.keys) {
      _subroutes.add(_mapDefinition(this, segment, definition[segment]));
    }
  }
}