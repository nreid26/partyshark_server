/// A utility class implementing random value generation functions needed by the server.
library randomization_service;

import 'dart:core' hide Resource;
import 'dart:math' show Random, min;
import 'dart:async' show Future, Stream;
import 'dart:convert' show UTF8, LineSplitter;
import 'package:resource/resource.dart' show Resource;

/// Indicator for when library is ready to be used.
///
/// [randomization_service] requires some resources to be loaded asynchronously.
/// This process is initiated automatically and is guaranteed to be complete
/// when this [Future] completes. Functions in this library may throw errors if
/// they are used before that time.
final Future ready = (() async {
  const String packageBase = 'package:partyshark_server/src/randomization_service';

  Future<Map> mapFromFile(Resource resc, Map map) =>
      resc.openRead()
        .transform(UTF8.decoder)
        .transform(const LineSplitter())
        .listen((String word) {
          if(word.length < 3) { return; }

          int key = word.codeUnitAt(0);
          map.putIfAbsent(key, () => new Set<String>());
          map[key].add(word);
        })
        .asFuture(map);

  await mapFromFile(const Resource('$packageBase/adjectives.txt'), _adjectives);
  await mapFromFile(const Resource('$packageBase/animals.txt'), _animals);

  //Generate distribution of potential names
  int sum = 0;
  for(int key in _animals.keys) {
    sum += _animals[key].length * (_adjectives[key]?.length ?? 0);
    _distribution.add(new _Pair(key, sum));
  }

  return null;
})();



/// A sorted string containing all the lowercase characters.
const String lowercaseAlphabet = 'abcdefghijklmnopqrstuvwxyz';

/// The internal random number generator at the core of the provided services.
final Random _rand = new Random();

/// File data for use in [username] service.
final Map<int, Set<String>> _animals = { }, _adjectives = { };
final List<_Pair> _distribution = [];

class _Pair {
  final int key, max;
  _Pair(this.key, this.max);
}



/// An internal function returning a random non-negative integer with the
/// specified number of bits
int _randIntBits(int bits) {
  int ret = 0;

  while (bits > 0) {
    int toGen = min(bits, 32);
    bits -= toGen;

    ret = (ret << toGen) | _rand.nextInt(1 << toGen);
  }

  return ret;
}

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
  int key = _rand.nextInt(_distribution.last.max);

  for(_Pair p in _distribution) {
    if (key < p.max) {
      key = p.key;
      break;
    }
  }

  return draw(_adjectives[key]) + '_' + draw(_animals[key]);
}

/// Service for retrieving a random administrator code.
int get adminCode => _randIntBits(24);

/// Service for retrieving a random user code.
int get userCode => _randIntBits(64);
