library server_lib;

import 'dart:io';
import 'dart:math' show Random;
import 'dart:convert' show JSON, BASE64;
import 'dart:typed_data';

import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/pseudobase/pseudobase.dart';
import 'package:partyshark_server/src/entities/entities.dart';

part './partyshark_controller.dart';
part './parties_controller.dart';
part './rand_service.dart';

///A namespace class defining [String] constants naming custom HTTP headers
/// used by this library.
class _CustomHeader {
  static const String
    SetUsercode = 'X-Set-Usercode',
    Usercode = 'X-Usercode',
    Location = 'Location';

  _CustomHeader._internal();
}

///A namespace class defining [PathParameterKey] constants used by this
/// library.
class PathKey {
  static final PathParameterKey
    PartyCode = new PathParameterKey(),
    Username = new PathParameterKey(),
    PlaythroughCode = new PathParameterKey(),
    TransferRequestCode = new PathParameterKey(),
    SongCode = new PathParameterKey();

  PathKey._internal();
}

///A convenience function for converting an [int] to a Base64 [String] with
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

///A convenience function for converting a Base 64 [String] to an [int] with
/// preserved endianness.
int decodeBase64(String value) {
  List<int> l = BASE64.decode(value);
  int ret = 0;

  for(int i in l) {
    ret <<= 8;
    ret |= i;
  }

  return ret;
}