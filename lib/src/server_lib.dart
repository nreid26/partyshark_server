library server_lib;

import 'dart:io';
import 'dart:math';

import 'package:partyshark_server/signpost.dart';
import 'package:partyshark_server/pseudobase.dart';
import 'package:partyshark_server/src/entities.dart';

part './server_lib/partyshark_controller.dart';
part './server_lib/parties_controller.dart';

final Random _serverRand = new Random();

///A namespace class defining [String] constants naming custom HTTP headers
/// used by this library.
class _CustomHeader {
  static const String
    SetUsercode = 'X-Set-Usercode',
    Usercode = 'X-Usercode';

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