part of pseudobase;

///A class representing a table of objects in a Datastore
class Table<T extends Identifiable> extends SetBase<T> {
  //Statics
  static const int _jump = 11;
  static const double _fillFactor = 0.75;

  //Data
  int _maxIdentity, _length;
  List<T> _cells;
  final Datastore datastore;

  //Constructor
  Table._internal(this.datastore) {
    clear();
  }

  ///The number of items in the table.
  int get length => _length;

  ///Returns an item from within the table with the provided [identity] is such
  /// and item exists; returns null otherwise.
  T operator[](int identity) {
    int index = _search(identity);
    return (index >= 0) ? _cells[index] : null;
  }

  ///Insert [item] into the [Table] if no item with the same identity is
  /// present. If the identity of the [item] has not been
  /// set, an identity that is not currently in use within the [Table] will
  /// be assigned. Returns true if the insertion is successful and false
  /// otherwise.
  bool add(T item) {
    if(!item.hasIdentity) { item.identity = ++_maxIdentity; }
    else if(item.identity > _maxIdentity) { _maxIdentity = item.identity; }

    int index = _search(item.identity);
    if(index < 0) {
      _length++;
      _cells[-(index + 1)] = item;
      if(_length / _cells.length >= _fillFactor) { _expand(); }
      return true;
    }
    return false;
  }

  ///Remove an element from the [Table] with the provided [identity]. Returns
  /// true if such an element existed and false otherwise.
  bool removeIdentity(int identity) {
    int index = _search(identity);
    if(index >= 0) {
      _length--;
      _cells[index] = null;
      return true;
    }
    return false;
  }

  bool remove(T item) => removeIdentity(item.identity);

  ///Determine any element in the [Table] has the provided [identity].
  bool containsIdentity(int identity) => _search(identity) >= 0;

  bool contains(T item) => containsIdentity(item.identity);

  ///Return an element from the [Table] with the same [identity] as [item].
  ///  Returns [null] if no such element exists.
  T lookup(T item) => this[item.identity];

  Iterator<T> get iterator => new _TableIterator(this);

  void clear() {
    _length = 0;
    _cells = new List<T>(16);
    _maxIdentity = -1;
  }

  Set<T> toSet() => new HashSet<T>.from(this);

  ///Run a single hashing search over the table. A negative values indicate an
  /// open space where an element with the provided [identity] could go;
  /// non-negative values indicate that a mtaching element has been found at
  /// that location. To extract a viable position from a netative return, add
  /// one and negate.
  int _search(int identity) {
    int index = identity % _cells.length;

    while(true) {
      if(_cells[index] == null) { return -(index + 1); }
      else if(_cells[index].identity == identity) { return index; }
      else { index = (index + _jump) % _cells.length; }
    }
  }

  ///Double the capacity of the [Table] and reinsert the existing values to
  /// preserve their hashed order.
  void _expand() {
    int oldLength = length;
    List<Identifiable> oldCells = _cells;
    _cells = new List<Identifiable>(2 * oldCells.length);

    for(T t in oldCells) {
      if(t != null) { add(t); }
    }
    _length = oldLength;
  }
}

///A forward Iterator implementation of the Table
class _TableIterator<T extends Identifiable> implements Iterator<T> {
  //Data
  final Table<T> _table;
  int _index = -1;

  //Constructor
  _TableIterator(this._table);

  //Methods
  T get current => _table._cells[_index];

  bool moveNext() {
    while(_index + 1 < _table._cells.length) {
      if(_table._cells[++_index] != null) {
        return true;
      }
    }
    return false;
  }
}