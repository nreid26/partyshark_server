library identity;

/// An interface for types with [identity]. Types implementing this interface
/// should override operator [==] and [hashCode] to depend only on their
/// [identity] property. [IdentifiableMixin] provides a reference implementation
/// of these overrides.
abstract class Identifiable {
  int get identity;
}

/// An interface extending [Identifiable] to support types with mutable
/// [identity] properties. Types implementing this interface should override
/// their operator '==' and [hashCode] to depend only on their
/// [identity] property. [IdentifiableMixin] provides a reference implementation
/// of these overrides.
abstract class MutableIdentifiable implements Identifiable {
  void set identity(int id);

  /// Returns true if [identity] is defined on this and false otherwise.
  bool get hasIdentity;
}

/// A mixin defining reference implementations of various behaviours of an
/// [Identifiable] which are functionally dependent on [identity].
abstract class IdentifiableMixin implements Identifiable {
  /// Returns the [identity] of this truncated to 32 bits.
  int  get hashCode => identity & 0xFFFFFFFF;

  /// Redefines equality based on [Type] and [identity].
  bool operator==(Identifiable other) =>
      identical(runtimeType, other.runtimeType) && identical(identity, other.identity);

  /// Redefines the [String] representation of this to include its [Type] name
  /// and [identity].
  String toString() => '$runtimeType: $identity';
}


/// A mixin defining an [Identifiable] that allows its [identity] to be set
/// only once following construction. Accessing [identity] before it is set or
/// setting it a second time will throw a [StateError].
abstract class DeferredIdentifiable implements MutableIdentifiable {
  //Data
  int _identity;

  //Methods
  int  get identity {
    if(hasIdentity) { return _identity; }
    else { throw new StateError('Identity has not been assigned.'); }
  }

  void set identity(int id) {
    if(hasIdentity) { throw new StateError('Identity may only be set once.'); }
    else { _identity = id; }
  }

  /// Returns true if [identity] is defined on this and false otherwise.
  bool get hasIdentity => _identity != null;
}