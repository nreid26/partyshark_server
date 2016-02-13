library signpost;

import 'dart:io';
import 'dart:convert' show JSON;
import 'dart:async' show Future;
import 'dart:mirrors';

part './router.dart';
part './route_controller.dart';


/// A convenience function for generating a basic error in JSON format.
String errorJson(String what, String why) => '{"what":${JSON.encode(what)},"why":${JSON.encode(why)}}';

/// A trivial extension of [ArgumentError] denoting a specific kind of error
/// during a [Router] definition.
class RouterDefinitionError extends ArgumentError {
  RouterDefinitionError([String message]): super(message);
}

/// An identity class designed to denote path parameters in a [Router]
/// definition. These objects have no properties beyond uniqueness and type.
class RouteKey {
  RouteKey._internal();
  factory RouteKey() = RouteKey._internal;
}

/// An annotation class for marking methods in a [RouteController] subclass as
/// handlers for HTTP requests.
class HttpHandler {

  /// The name of the HTTP method that the method this object annotates is
  /// intended to handle.
  final String methodName;

  /// A simple constant constructor.
  const HttpHandler(this.methodName);
}

/// A class that holds the information required within a routing tree. Each
/// [_Route] is a node.
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

/// A namespace class defining [String] constants naming common HTTP methods.
abstract class HttpMethod {
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

  HttpMethod._internal();
}


