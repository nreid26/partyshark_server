library identity;

///The interface of an identifiable object. When used my client code, distinct objects with the same identity should not coexist within the same structure.
abstract class Identifiable {
  //Methods
  int get identity;

  int get hashCode => identity;
  bool operator==(Identifiable other) => identical(runtimeType, other.runtimeType) && identical(identity, other.identity);

  String toString() => '${runtimeType.toString()}: $identity';
}