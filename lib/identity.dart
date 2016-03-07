///A library providing support for objects with identity.
///
/// Interfaces,
library identity;


/// An interface for types with [identity].
///
/// [identity] must not be null when used. Types implementing this interface
/// must also implement the following forwards. If convenient, this can be
/// achieved by applying [IdentifiableMixin].
/// - [operator==] => [referenceEquals]
/// - [hashCode] => [referenceHashcode]
/// - [toString] => [referenceToString]
abstract class Identifiable {
  int get identity;

  /// The reference implementation of operator [==] for [Identifiable] types.
  static bool referenceEquals(Identifiable a, Identifiable b) {
    if ((a != null && a.identity == null) || (b != null && b.identity == null)) {
      throw new StateError('identity cannot be compared while null');
    }

    /// Same type, same identity, not null
    return identical(a.runtimeType, b.runtimeType) &&
        identical(a.identity, b.identity) &&
        a != null;
  }


  /// The reference implementation of [hashcode] for [Identifiable] types.
  ///
  /// This function makes the additional guarantee that the result will never be
  /// negative.
  static int referenceHashCode(int identity) {
    if (identity == null) {
      throw new StateError('identity cannot be hashed while null');
    }

    return identity.abs();
  }

  /// The reference implementation of [toString] for [Identifiable] types.
  static String referenceToString(Identifiable i) =>
      '${i.runtimeType}: ${i.identity}';
}


/// An interface extending [Identifiable] to support types with mutable
/// [identity] properties.
///
/// Types implementing this interface must also implement the same methods
/// forwards mandated by [Identifiable]. [identity] must only be null before
/// it is first set.
abstract class MutableIdentifiable implements Identifiable {
  void set identity(int i);
  bool get hasIdentity;
}


/// A mixin implementing forwards to reference implementations of various
/// methods and properties which are functionally dependent on [identity].
abstract class IdentifiableMixin implements Identifiable {
  bool operator==(Identifiable other) => Identifiable.referenceEquals(this, other);

  int get hashCode => Identifiable.referenceHashCode(identity);

  String toString() => Identifiable.referenceToString(this);
}


/// A mixin defining an [Identifiable] that allows its [identity] to be set
/// only once following construction. Setting [identity]a second time will
/// throw a [StateError].
abstract class DeferredIdentifiableMixin implements MutableIdentifiable {
  //Data
  int __identity;

  //Methods
  bool get hasIdentity => __identity != null;

  int  get identity {
    if (!hasIdentity) { return identity; }
    throw new StateError('identity moy not be used before being set.');
  }

  void set identity(int i) {
    if (hasIdentity) { throw new StateError('identity may only be set once.'); }
    else { __identity = i; }
  }

  bool operator==(Identifiable other) => Identifiable.referenceEquals(this, other);

  int get hashCode => Identifiable.referenceHashCode(identity);

  String toString() => Identifiable.referenceToString(this);
}
