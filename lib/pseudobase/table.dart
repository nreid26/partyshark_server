part of pseudobase;

///A class representing a table of objects in a Datastore
class Table<T extends Identifiable> extends Object with SetBase<T> {
  //Statics
  static bool _internalEquals(a, b) {
    if(a == b) { return true; }
    else if(a is Identifiable) { return a.identity == b; }
    else if(b is Identifiable) { return b.identity == a; }
    else { return false; }
  }

  //Data
  int _maxIdentity = 0;
  Set<T> _core = new HashSet<T>(equals: _internalEquals);

  //Constructor
  Table._internal();

  //Methods
  T operator[](int identity) => _core.lookup(identity);

  int get nextIdentity => _maxIdentity + 1;

  bool add(T item) {
    if(item.identity > _maxIdentity) { _maxIdentity = item.identity; }
    return _core.add(item);
  }

  T lookup(T item) => _core.lookup(item);

  Iterator<T> get iterator => _core.iterator;

  bool contains(T item) => _core.contains(item);

  Set<T> toSet() => _core.toSet();

  bool remove(T item) => _core.remove(item);

  int get length => _core.length;

  void clear() => _core.clear();
}