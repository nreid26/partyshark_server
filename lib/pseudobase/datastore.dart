part of pseudobase;

/// A class representing an object database but lacking long-term storage
class Datastore {
  //Static
  static final TypeMirror _identifiableMirror = reflectType(Identifiable);

  //Data
  final Map<Type, Table> _tables = new HashMap();

  /// The basic generative constructor of a [Datastore]. For each [Type] in the
  /// provided [List] of types, a [Table] containing that type will be created
  /// within the store. If any of the provided types are a assignable to one
  /// another relationship or are not assignable to [Identifiable] this
  /// constructor throws an [ArgumentError].
  Datastore(List<Type> types) {
    Set<TypeMirror> mirrors = new Set<TypeMirror>();

    for(Type type in types) {
      TypeMirror tm = reflectType(type);

      if (!tm.isAssignableTo(_identifiableMirror)) {
        throw new ArgumentError('All ${Table}s in a $Datastore must have types which are assignable to Identifiable');
      }
      else if(mirrors.any((TypeMirror om) => om.isAssignableTo(tm) || tm.isAssignableTo(om))) {
        throw new ArgumentError('No two tables in a $Datastore may have types whise are assignable to one another');
      }
      else {
        _tables[type] = new Table._internal(this);
        mirrors.add(tm);
      }
    }
  }

  /// A convenience method that forwards the addition of [item] to a [Table] of
  /// the same type as [item]. Returns true if the addition succeeds and false
  /// otherwise. Throws an [ArgumentError] of no suitable [Table] exists.
  bool add(Identifiable item) => this[item.runtimeType].add(item);

  /// A convenience method that forwards the removal of [item] to a [Table] of
  /// the same type as [item]. Returns true if the removal was possible and
  /// false otherwise. Throws an [ArgumentError] of no suitable [Table] exists.
  bool remove(Identifiable item) => this[item.runtimeType].remove(item);

  /// Returns a {Table] of type [type] from the store if one exists; otherwise
  /// throws an [ArgumentError] since all types with the store should be known
  /// statically.
  Table operator[](Type type) {
    if(hasTable(type)) { return _tables[type]; }
    else { throw new ArgumentError('No Table exists for the specified Type.'); }
  }

  /// Returns true of this [Datastore] contains a [Table] of type [type]; returns
  /// false otherwise.
  bool hasTable(Type type) => _tables.containsKey(type);
}