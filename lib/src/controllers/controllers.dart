library controllers;

import 'dart:io' show HttpRequest, HttpResponse, HttpHeader, HttpStatus, ContentType;
import 'dart:convert' show JSON, UTF8;
import 'dart:async' show Future;

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

/// A namespace class defining [RouteController] constatnts from this library.
class Controller {
  static final PartyController Party = new PartyController._();
  static final PartiesController Parties = new PartiesController._();
  static final PlaylistController Playlist = new PlaylistController._();
  static final PlaythroughController Playthrough = new PlaythroughController._();
  static final SettingsController Settings = new SettingsController._();
  static final UsersController Users = new UsersController._();
  static final UserController User = new UserController._();
  static final SelfController Self = new SelfController._();
  static final PlayerTransferController Transfer = new PlayerTransferController._();
  static final PlayerTransfersController Transfers = new PlayerTransfersController._();

  Controller.__();
}