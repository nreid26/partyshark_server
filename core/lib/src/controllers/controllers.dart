library controllers;

import 'dart:io' show HttpRequest, HttpResponse, HttpHeader, HttpStatus, ContentType;
import 'dart:convert' show JSON, UTF8;
import 'dart:async' show Future;

import 'package:logging/logging.dart';

import 'package:partyshark_server/src/messaging/messaging.dart';
import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/src/model/model.dart';


part './partyshark_controller.dart';
part './misc_classes.dart';

part './concrete/parties_controller.dart';
part './concrete/party_controller.dart';
part './concrete/playlist_controller.dart';
part './concrete/playthrough_controller.dart';
part './concrete/settings_controller.dart';
part './concrete/users_controller.dart';
part './concrete/self_controller.dart';
part './concrete/user_controller.dart';
part './concrete/player_transfer_controller.dart';
part './concrete/player_transfers_controller.dart';

/// A namespace class defining [RouteKey] constants used by this library.
class Key {
  static final RouteKey
      PartyCode = new RouteKey(),
      Username = new RouteKey(),
      PlaythroughCode = new RouteKey(),
      PlayerTransferCode = new RouteKey();

  Key.__();
}

class ControllerSet {
  final PartyController party = new PartyController._();
  final PartiesController parties = new PartiesController._();
  final PlaylistController playlist = new PlaylistController._();
  final PlaythroughController playthrough = new PlaythroughController._();
  final SettingsController settings = new SettingsController._();
  final UsersController users = new UsersController._();
  final UserController user = new UserController._();
  final SelfController self = new SelfController._();
  final PlayerTransferController transfer = new PlayerTransferController._();
  final PlayerTransfersController transfers = new PlayerTransfersController._();

  final PartysharkModel model;

  ControllerSet(this.model) {
    var all = [party, parties, playlist, playthrough, settings, users, self, transfer, transfers];

    for (PartysharkController con in all) {
      con._parentSet = this;
    }
  }
}