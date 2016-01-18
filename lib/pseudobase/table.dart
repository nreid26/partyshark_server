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

  //Methods
  int get nextIdentity => _maxIdentity + 1;

  int get length => _length;

  T operator[](int identity) {
    int index = _search(identity);
    return (index >= 0) ? _cells[index] : null;
  }

  bool add(T item) {
    if(item.identity > _maxIdentity) { _maxIdentity = item.identity; }

    int index = _search(item.identity);
    if(index < 0) {
      _length++;
      _cells[-(index + 1)] = item;
      if(_length / _cells.length >= _fillFactor) { _expand(); }
      return true;
    }
    return false;
  }

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

  bool containsIdentity(int identity) => _search(identity) >= 0;

  bool contains(T item) => containsIdentity(item.identity);

  T lookup(T item) => this[item.identity];

  Iterator<T> get iterator => new _TableIterator(this);

  void clear() {
    _length = 0;
    _cells = new List<T>(16);
    _maxIdentity = -1;
  }

  Set<T> toSet() => new HashSet<T>.from(this);


  int _search(int identity) {
    int index = identity % _cells.length;

    while(true) {
      if(_cells[index] == null) { return -(index + 1); }
      else if(_cells[index].identity == identity) { return index; }
      else { index = (index + _jump) % _cells.length; }
    }
  }

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