library controllers;

import 'dart:io' show HttpRequest, HttpResponse, HttpHeader, HttpStatus, ContentType;
import 'dart:convert' show JSON, BASE64, UTF8;
import 'dart:typed_data' show Uint8ClampedList;
import 'dart:async' show Future;

import 'package:partyshark_server/src/messaging/messaging.dart';

import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/pseudobase/pseudobase.dart';
import 'package:partyshark_server/src/entities/entities.dart';
import 'package:partyshark_server/src/randomization_service/randomization_service.dart' as rand_serve;
import 'package:partyshark_server/deezer.dart' as deezer;


part './partyshark_controller.dart';
part './misc_classes.dart';
part './misc_functions.dart';

part './concrete/parties_controller.dart';
part './concrete/party_controller.dart';
part './concrete/playlist_controller.dart';
part './concrete/playthrough_controller.dart';
part './concrete/settings_controller.dart';
part './concrete/song_controller.dart';
part './concrete/songs_controller.dart';


/// Indicator for when library is ready to be used.
///
/// [controllers] requires some resources to be loaded asynchronously.
/// This process is initiated automatically and is guaranteed to be complete
/// when this [Future] completes. Functions in this library may throw errors if
/// they are used before that time.
final Future ready = rand_serve.ready;

Datastore model;


