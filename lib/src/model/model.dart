library model;

import 'dart:async' show Future;

import 'package:logging/logging.dart';
import 'package:partyshark_server/pseudobase/pseudobase.dart';
import 'package:partyshark_server/src/entities/entities.dart';
import 'package:partyshark_server/src/randomization_service/randomization_service.dart' as rand_serve;
import 'package:partyshark_server/deezer.dart' as deezer;

export 'package:logging/logging.dart';

part './public.dart';
part './private.dart';


final Datastore _datastore = new Datastore(const [Ballot, Party, PlayerTransfer, Playthrough, SettingsGroup, Song, User]);

Logger get logger => Logger.root;
