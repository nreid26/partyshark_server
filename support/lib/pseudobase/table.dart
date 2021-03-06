part of pseudobase;

/// A singleton class whose instance is used to mark deletions in a [Table].
class _Deleted extends IdentifiableMixin {
  final int identity = 0;
  _Deleted.__();
  static final _Deleted only = new _Deleted.__();
}

/// A class representing a table of objects in a Datastore.
class Table<T extends Identifiable> extends SetBase<T> {
  //Statics
  static const int _jump = 11;
  static const double _fillFactor = 0.75;

  //Data
  int __maxIdentity, __length, __deletedCount;
  List<Identifiable> __cells;
  final Datastore datastore;

  //Constructor
  Table._(this.datastore) {
    clear();
  }

  /// The number of items in this.
  int get length => __length;

  ///  A guaranteed free identity in this.
  int get freeIdentity => __maxIdentity + 1;

  bool __isDeleted(int index) => identical(__cells[index], _Deleted.only);

  /// Returns an item from within the table with the provided [identity] is such
  /// and item exists; returns null otherwise.
  T operator[](int identity) {
    if (identity == null) { return null; }

    int index = __search(identity);
    return (index.isNegative) ? null : __cells[index];
  }

  /// Insert [item] into the [Table] if no item with the same identity is
  /// present.
  ///
  /// If [item] is a [MutableIdentifiable] and its identity has not
  /// been set, an identity that is not currently in use within the [Table] will
  /// be assigned. Returns true if the insertion is successful and false
  /// otherwise.
  bool add(T item) {
    if (item == null) { return false; }

    if(item is MutableIdentifiable) {
      var i = item as MutableIdentifiable;
      if (!i.hasIdentity) { i.identity = ++__maxIdentity; }
    }

    if(item.identity > __maxIdentity) { __maxIdentity = item.identity; }

    int index = __search(item.identity);
    if(index.isNegative) {
      index = -(index + 1);

      __length++;
      if(__isDeleted(index)) { __deletedCount--; }
      __cells[index] = item;

      if(__length + __deletedCount >= __cells.length * _fillFactor) {
        if(__length >= (__length + __deletedCount) * _fillFactor) { __expand(); }
        else { __scrub(); }
      }
      return true;
    }
    return false;
  }

  /// Remove an element from the [Table] with the provided [identity]. Returns
  /// true if such an element existed and false otherwise.
  bool removeIdentity(int identity) {
    if (identity == null) { return false; }

    int index = __search(identity);
    if(!index.isNegative) {
      __length--;
      __deletedCount++;
      __cells[index] = _Deleted.only;
      return true;
    }
    return false;
  }

  bool remove(T item) => (item == null) ? false : removeIdentity(item.identity);

  /// Determine any element in the [Table] has the provided [identity].
  bool containsIdentity(int identity) => (identity == null) ? false : __search(identity) >= 0;

  bool contains(T item) => (item == null) ? false : containsIdentity(item.identity);

  /// Return an element from the [Table] with the same [identity] as [item].
  /// Returns null if no such element exists.
  T lookup(T item) => (item == null) ? null : this[item.identity];

  Iterator<T> get iterator => new _TableIterator(this);

  void clear() {
    __length = 0;
    __deletedCount = 0;
    __cells = new List<T>(16);
    __maxIdentity = -1;
  }

  Set<T> toSet() => new HashSet<T>.from(this);

  /// Run a single hashing search over the table. A negative values indicate an
  /// open space where an element with the provided [identity] could go;
  /// non-negative values indicate that a matching element has been found at
  /// that location. To extract a viable position from a netative return, add
  /// one and negate.
  int __search(int identity) {
    int index = Identifiable.referenceHashCode(identity) % __cells.length,
        firstFree = -1;

    while(true) {
      if(__cells[index] == null) {
        if(firstFree >= 0) { index = firstFree; }
        return -(index + 1);
      }
      else if(__isDeleted(index)) {
        if(firstFree < 0) { firstFree = index; }
      }
      else if(__cells[index].identity == identity) { return index; }

      index = (index + _jump) % __cells.length;
    }
  }

  /// Remove all deleted markers from the [Table] and reinsert the real entries.
  /// Setting [expand] to true will simultaneously double the capacity of the
  /// [Table].
  void __scrub([bool expand = true]) {
    List<Identifiable> newCells =
        new List<Identifiable>((expand ? 2 : 1) * __cells.length);

    for(T t in this) {
      int index = Identifiable.referenceHashCode(t.identity) % newCells.length;
      while(newCells[index] != null) {
        index = (index + _jump) % newCells.length;
      }
      newCells[index] = t;
    }

    __cells = newCells;
    __deletedCount = 0;
  }

  /// Double the capacity of the [Table] and remove all deleted markers at the
  /// same time.
  void __expand() => __scrub(true);

  bool _advanceIterator(_TableIterator itr) {
    while(++itr._index < __cells.length) {
      T t = __cells[itr._index];
      if(t == null || __isDeleted(itr._index)) { continue; }

      itr._current = t;
      return true;
    }
    return false;
  }
}

/// A forward [Iterator] implementation on the Table
class _TableIterator<T extends Identifiable> implements Iterator<T> {
  //Data
  final Table<T> __table;
  int _index = -1;
  T _current = null;

  //Constructor
  _TableIterator(this.__table);

  //Methods
  T get current => _current;

  bool moveNext() => __table._advanceIterator(this);
}