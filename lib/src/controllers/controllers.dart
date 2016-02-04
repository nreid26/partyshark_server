library controllers;

import 'dart:io';
import 'dart:convert' show JSON, BASE64;
import 'dart:typed_data' show Uint8ClampedList;
import 'dart:async' show Future;

import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/pseudobase/pseudobase.dart';
import 'package:partyshark_server/src/entities/entities.dart';
import 'package:partyshark_server/src/randomization_service/randomization_service.dart' as rand_serve;

part './partyshark_controller.dart';
part './parties_controller.dart';
part './party_controller.dart';

/// Indicator for when library is ready to be used.
///
/// [controllers] requires some resources to be loaded asynchronously.
/// This process is initiated automatically and is guaranteed to be complete
/// when this [Future] completes. Functions in this library may throw errors if
/// they are used before that time.
final Future ready = rand_serve.ready;

/// A namespace class defining [String] constants naming HTTP headers
/// used by this library.
class _CustomHeader {
  static const String
    SetUserCode = 'X-Set-User-Code',
    UserCode = 'X-User-Code',
    Location = 'Location';

  _CustomHeader.__internal();
}

/// A namespace class defining [PathParameterKey] constants used by this
/// library.
class PathKey {
  static final PathParameterKey
    PartyCode = new PathParameterKey(),
    Username = new PathParameterKey(),
    PlaythroughCode = new PathParameterKey(),
    TransferRequestCode = new PathParameterKey(),
    SongCode = new PathParameterKey();

  PathKey.__internal();
}

/// A convenience function for converting an [int] to a Base64 [String] with
/// preserved endianness.
String encodeBase64(int value, [int bytes = -1]) {
  bytes = bytes.isNegative ? (value.bitLength ~/ 8 + 1) : bytes;
  Uint8ClampedList l = new Uint8ClampedList(bytes);

  for(int i = l.length - 1; i >= 0; i--) {
    l[i] = value;
    value >>= 8;
  }

  return BASE64.encode(l);
}

/// A convenience function for converting a Base64 [String] to an [int] with
/// preserved endianness.
int decodeBase64(String value) {
  if(value == null) { return null; }

  List<int> l;
  int ret = 0;

  try { l = BASE64.decode(value); }
  catch (e) { return null; }

  for(int i = 0; i < l.length; i++) {
    ret <<= 8;
    ret |= l[i];
  }

  return ret;
}