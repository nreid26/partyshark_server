library identity;

///The interface of an identifiable object with default properties suitable
/// for use as a mixin. When used by client code, distinct objects with the
/// same identity should not coexist within the same structure.
abstract class Identifiable {
  //Statics
  static const int _key = 1282724092;

  //Data
  int _identity;

  //Methods
  int  get identity {
    if(hasIdentity) {
      return _identity;
    }
    else {
      throw new StateError('Identity has not been assigned');
    }
  }

  void set identity(int id) {
    if(hasIdentity) {
      throw new StateError('Identity may only be set once');
    }
    else {
      _identity = id;
    }
  }

  int  get hashCode => identity;

  ///Determine whether this [Identifiable]'s [identity] has been set.
  bool get hasIdentity => _identity != null;

  bool operator==(Identifiable other) => identical(runtimeType, other.runtimeType) && identical(identity, other.identity);

  String toString() => '$runtimeType: $identity';
}