/// A utility class implementing random value generation functions needed by the server.
library randomization_service;

import 'dart:core' hide Resource;
import 'dart:math' show Random, min;
import 'dart:async' show Future, Stream;
import 'dart:convert' show UTF8, LineSplitter;

import 'package:resource/resource.dart' show Resource;
import 'package:logging/logging.dart';

part './username_generator.dart';

/// Indicator for when library is ready to be used.
///
/// [randomization_service] requires some resources to be loaded asynchronously.
/// This process is initiated automatically and is guaranteed to be complete
/// when this [Future] completes. Functions in this library may throw errors if
/// they are used before that time.
final Future ready = _UsernameGenerator._onlyReady
  ..then((v) => logger.info('randomization_service assets loaded'));

Logger logger;

/// A sorted string containing all the lowercase characters.
const String lowercaseAlphabet = 'abcdefghijklmnopqrstuvwxyz';
const String packageBase = 'package:partyshark_server/src/randomization_service';

/// The internal random number generator at the core of the provided services.
final Random _rand = new Random();



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


/// Service for retrieving a random administrator code.
int get adminCode => _randIntBits(24);

/// Service for retrieving a random user code.
int get userCode => _randIntBits(64);

/// Service for retrieving a random username.
String get username => _UsernameGenerator._only.generate();


