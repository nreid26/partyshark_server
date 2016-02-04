/// A utility class implementing random value generation functions needed by the server.
library randomization_service;

import 'dart:math' show Random;
import 'dart:async' show Future, Stream;
import 'dart:convert' show UTF8, LineSplitter;

/// Indicator for when library is ready to be used.
///
/// [randomization_service] requires some resources to be loaded asynchronously.
/// This process is initiated automatically and is guaranteed to be complete
/// when this [Future] completes. Functions in this library may throw errors if
/// they are used before that time.
final Future ready = (() async {
  const String packageBase = 'package:partyshark_server/src/randomization_service';

  Future<Map> fillMapFromFile(Resource resc, Map map) =>
    resc.openRead()
        .transform(UTF8.decoder)
        .transform(const LineSplitter())
        .listen((String word) {
          int key = word.codeUnitAt(0);
          map.putIfAbsent(key, () => new Set<String>());
          map[key].add(word);
        })
        .asFuture(map);

  await fillMapFromFile(const Resource('$packageBase/adjectives.txt'), _adjectives);
  await fillMapFromFile(const Resource('$packageBase/animals.txt'), _animals);

  return null;
})();



/// A sorted string containing all the lowercase characters.
const String lowercaseAlphabet = 'abcdefghijklmnopqrstuvwxyz';

/// The internal random number generator at the core of the provided services.
final Random _rand = new Random();

/// File data for use in [username] service.
final Map<String, Set<String>> _animals = { }, _adjectives = { };



/// An internal function returning a random non-negative integer with the
/// specified number of bits
int _randIntBits(int bits) => _rand.nextInt(1 << bits);

/// Returns an entry at random from the provided structure. May be a [String],
/// [Map], or [Iterable]. If a seed is provided the result is fully
/// deterministic.
dynamic draw(dynamic struct, [int seed]) {
  if(struct == null || struct.length == 0) { return null; }

  seed = (seed == null)
      ? _rand.nextInt(struct.length)
      : seed % struct.length;

  if(struct is String) { return struct[seed]; }
  if(struct is Map) { return struct.values.elementAt(seed); }
  else { return struct.elementAt(seed); }
}

/// Returns a random username based on the resource files in this library.
String get username {
  int key;
  String adj, ani;

  do {
    key = draw(_adjectives.keys);
    adj = draw(_adjectives[key]);
    ani = draw(_animals[key]);
  } while(adj == null || ani == null);

  return adj + '_' + ani;
}

/// Service for retrieving a random administrator code.
int get adminCode => _randIntBits(24);

/// Service for retrieving a random user code.
int get usercode => _randIntBits(64);
