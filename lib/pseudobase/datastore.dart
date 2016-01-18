part of pseudobase;

///A class representing an object database but lacking long-term storage
class Datastore {
  //Static
  static TypeMirror _identifiableMirror = reflectType(Identifiable);

  //Data
  final List<_TableNode> _tables;

  //Constructor
  Datastore(List<Type> types): _tables = new List<_TableNode>(types.length) {
    int i = 0;
    for(Type type in types) {
      if (!reflectType(type).isSubtypeOf(_identifiableMirror)) {
        throw new ArgumentError('All Tables in a Datastore must have types which subclass Identifiable');
      }

      for(int j = 0; j < i; j++) {
        if(_search(type) >= 0) {
          throw new ArgumentError('Each Type may only have one associated Table in a Dattastore');
        }
      }

      _tables[i++] = new _TableNode(type, this);
    }
  }

  //Methods
  int _search(Type type) {
    for(int i = 0; i < _tables.length; i++) {
      if(type == _tables[i].type) { return i; }
    }
    return -1;
  }

  Table operator[](Type type) {
    int index = _search(type);
    if(index >= 0) { return _tables[index].table; }
    else { throw new ArgumentError('No Table exists for the specified Type.'); }
  }

  bool hasTable(Type type) => _search(type) >= 0;
}

///An internal class providing pairing between Types and Tables for uses in a Datastore
class _TableNode {
  //Data
  final Type type;
  final Table table;

  //Constructor
  _TableNode(this.type, Datastore parent): table = new Table._internal(parent);
}