part of randomization_service;

/// A class holding the data needed to generate usernames.
class _UsernameGenerator {
  // Statics
  static _UsernameGenerator _only;

  static final Future _onlyReady = (() async {
    var only = new _UsernameGenerator();
    await only.__readAdjectives();
    await only.__readAnimals();

    only.__adjectives.retainWhere((s) => only.__animals.containsKey(s.codeUnitAt(0)));

    _only = only;
  })();

  // Data
  final Set<String> __adjectives = new Set();
  final Map<int,  Set<String>> __animals = { };

  // Methods
  String generate() {
    String adj = draw(__adjectives);
    String ani = draw(__animals[adj.codeUnitAt(0)]);
    if (adj != null && ani != null) { return adj + '_' + ani; }

    throw new StateError('Could not generate username with adjective \'$adj\'');
  }

  Future __readAnimals() async {
    Resource resc = const Resource('$packageBase/animals.txt');
    Stream lines = resc.openRead().transform(UTF8.decoder).transform(const LineSplitter());

    await for(String word in lines) {
      if (word.length < 3) { continue; }

      int key = word.codeUnitAt(0);
      __animals.putIfAbsent(key, () => new Set<String>());
      __animals[key].add(word);
    }
  }

  Future __readAdjectives() async {
    Resource resc = const Resource('$packageBase/adjectives.txt');
    Stream lines = resc.openRead().transform(UTF8.decoder).transform(const LineSplitter());

    await for(String word in lines) {
      if (word.length < 3) { continue; }
      __adjectives.add(word);
    }
  }
}