library espionage;

/// A class that logs calls and impersonates another object for use in testing.
class Spy {
  /// Recover the private log of a [Spy] instance.
  static List<Invocation> readLog(Spy spy) => spy._log;

  //Data
  final List<Invocation> _log = [ ];
  final Map<String, dynamic> _properties = { };

  /// Overrides the default implementation to impersonate any setter, getter,
  /// or method call. Getters retrieve the values assigned by setters when
  /// possible and return a [Spy] when not. All methods also return a [Spy]
  /// when needed and all calls are logged by [Invocation].
  dynamic noSuchMethod(Invocation invocation) {
    _log.add(invocation);

    if(invocation.isSetter) {
      String prop = invocation.memberName.toString().replaceAll('=', '');
      _properties[prop] = invocation.positionalArguments.first;
    }
    else if(invocation.isGetter) {
      String prop = invocation.memberName.toString();

      if(!_properties.containsKey(prop)) {
        _properties[prop] = new Spy();
      }
      return _properties[prop];
    }
    else {
      return new Spy();
    }
  }
}