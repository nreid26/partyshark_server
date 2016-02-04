///A library providing support for objects with identity.
///
/// Interfaces,
library identity;


/// An interface for types with [identity].
///
/// [identity] must never be null. Types implementing this interface must also
/// implement the following forwards. If convenient, this can be achieved by
/// applying [IdentifiableMixin].
/// - [operator==] => [referenceEquals]
/// - [hashCode] => [referenceHashcode]
/// - [toString] => [referenceToString]
abstract class Identifiable {
  int get identity;

  /// The reference implementation of operator [==] for [Identifiable] types.
  static bool referenceEquals(Identifiable a, Identifiable b) =>
      identical(a.runtimeType, b.runtimeType) &&
      identical(a.identity, b.identity) &&
      a != null;

  /// The reference implementation of [hashcode] for [Identifiable] types.
  ///
  /// This function makes the additional guarantee that the result will never be
  /// negative.
  static int referenceHashCode(int identity) => identity.abs();

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
abstract class DeferredIdentifiable implements MutableIdentifiable {
  //Data
  int __identity;

  //Methods
  int  get identity => __identity;

  void set identity(int i) {
    if(__identity != null) { throw new StateError('Identity may only be set once.'); }
    else { __identity = i; }
  }
}