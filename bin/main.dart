import 'dart:io';
import 'dart:async' show Future;

import 'package:partyshark_server/pseudobase/pseudobase.dart';
import 'package:partyshark_server/src/controllers/controllers.dart' as controllers;
import 'package:partyshark_server/src/controllers/controllers.dart';
import 'package:partyshark_server/src/entities/entities.dart';
import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/src/logger.dart';

class RootController extends MisrouteController { }

main(List<String> arguments) async {
  await controllers.ready;

  logger
    ..level = Level.ALL
    ..onRecord.listen((rec) {
      print('${rec.level} ${rec.message} \n');
    });

  model = new Datastore([Ballot, Party, PlayerTransfer, Playthrough, SettingsGroup, Song, User]);

  var definition = {
    'parties': [Controller.Parties, {
      Key.PartyCode: [Controller.Party, {
        'playlist': [Controller.Playlist, {
          Key.PlaythroughCode: Controller.Playthrough
        }],
        'settings': Controller.Settings,
        'users':Controller.Users,
      }],
    }],
    'songs': [Controller.Songs, {
      Key.SongCode: Controller.Song
    }]
  };

  var router = new Router(arguments[0], new RootController(), definition);
  var server = await HttpServer.bind(InternetAddress.ANY_IP_V4, int.parse(arguments[1]));

  logger.shout('The PartyShark is swimming!');

  await for (Future res in server.map(router.routeRequest)) {
    try {
      await res;
    } catch (e, trace) {
      logger.severe('Router error', e, trace);
      if (e is Error) { rethrow; } // Errors should crash the server
    }

  }

  logger.severe('The PartyShark died!');
}
