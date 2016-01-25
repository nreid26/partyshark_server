library signpost;

import 'dart:io';
import 'dart:convert' show JSON;
import 'dart:collection' show UnmodifiableListView;

part './signpost/router.dart';
part './signpost/route_controller.dart';

//Helper classes
class PathParameterKey {
  //Constructor
  PathParameterKey._internal();
  factory PathParameterKey() = PathParameterKey._internal;
}

class _Route {
  //Data
  final _Route _parent;
  final List<_Route> _subroutes = [];
  final dynamic _segment; //String or PathParameterKey
  final RouteController _controller;

  //Constructor
  _Route(this._parent, this._segment, this._controller) {
    if(_parent != null) { _parent._subroutes.add(this); }
  }
}

class HttpMethod {
  static const String
    Connect = 'CONNECT',
    Delete = 'DELETE',
    Get = 'GET',
    Head = 'HEAD',
    Options = 'OPTIONS',
    Patch = 'PATCH',
    Post = 'POST',
    Put = 'PUT',
    Trace = 'TRACE';
}