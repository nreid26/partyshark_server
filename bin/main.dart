import 'dart:io';

import 'package:partyshark_server/pseudobase/pseudobase.dart';
import 'package:partyshark_server/src/controllers/controllers.dart';
import 'package:partyshark_server/src/entities/entities.dart';
import 'package:partyshark_server/signpost/signpost.dart';

class RootController extends MisrouteController { }

main(List<String> arguments) async {
  model = new Datastore([Ballot, Party, PlayerTransfer, Playthrough, SettingsGroup, Song, User]);

  var definition = {
    'parties': [partiesController, {
      CustomKey.PartyCode: [partyController, {
        'playlist': [playlistController, {
          CustomKey.PlaythroughCode: playthroughController
        }]
      }]
    }]
  };

  (await HttpServer.bind(InternetAddress.ANY_IP_V4, int.parse(arguments[1])))
      .listen(
          new Router(arguments[0], new RootController(), definition).routeRequest
      );
}
