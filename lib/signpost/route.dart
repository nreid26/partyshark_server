part of signpost;

class _Route {
  //Statics
  static ArgumentError _genError(dynamic problem, int pos, [Type expected, Type otherExpected]) =>
      new ArgumentError('Found a $problem at position $pos in List in $Router definition; expected a $expected ${otherExpected != null ? 'or $otherExpected' : ''}');

  static _Route _mapDefinition(parent, pattern, definition) {
    RouteController con, fall;
    Map<Pattern, dynamic> subs;

    //Pattern
    if(pattern == null) { throw new ArgumentError('Found null $Pattern in a $Router defenition'); }
    else if(pattern is String) { pattern = new RegExp(key); }

    //Argument extraction
    if(definition is RouteController) { con = definition; }
    else if(definition is Map) { subs = definition; }
    else if(definition is List) {
      if(definition.isNotEmpty) {
        if(definition[0] is RouteController) { con = definition[0]; }
        else { throw _genError(definition[0], 0, RouteController); }
      }

      if(definition.length == 2) {
        if(definition[1] is RouteController) { fall = definition[1]; }
        else if(definition[1] is Map) { subs = definition[1]; }
        else { throw _genError(definition[1], 1, RouteController, Map); }
      }
      else if(definition.length == 3) {
        if(definition[1] is RouteController) { fall = definition[1]; }
        else { throw _genError(definition[1], 1, RouteController); }

        if(definition[2] is Map) { subs = definition[2]; }
        else { throw _genError(definition[2], 2, Map); }
      }
      else { throw new ArgumentError('Found List of length ${definition.length} in $Router definition; expected length 2 or 3'); }
    }
    else { throw new ArgumentError('Found ${definition} in $Router definition; expected $RouterController, Map, or List'); }

    //Recursion
    return new _Route(parent, pattern, con, fall, subs);
  }

  //Data
  final _Route _parent;
  final List<_Route> _subroutes = [];
  final Pattern _pattern;
  final RouteController _controller, _fallback;

  //Constructor
  _Route(this._parent, this._pattern, this._controller, this._fallback, Map<Pattern, dynamic> definition) {
    if(definition == null) { return; }
    for(Pattern pattern in definition.keys) {
      _subroutes.add(_mapDefinition(_parent, pattern, definition[p]));
    }
  }
}