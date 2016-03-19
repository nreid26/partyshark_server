import 'dart:io';
import 'dart:async';

import 'package:partyshark_server/src/controllers/controllers.dart';
import 'package:partyshark_server/src/randomization_service/randomization_service.dart' as rand_serve show ready;
import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/src/model/model.dart' as model;

final _definition = {
  'parties': [Controller.Parties, {
    Key.PartyCode: [Controller.Party, {
      'playlist': [Controller.Playlist, {
        Key.PlaythroughCode: Controller.Playthrough
      }],
      'settings': Controller.Settings,
      'users': [Controller.Users, {
        'self': Controller.Self,
        Key.Username: Controller.User
      }],
      'playertransfers': [Controller.Transfers, {
        Key.PlayerTransferCode: Controller.Transfer
      }]
    }],
  }]
};

Future<StreamSubscription> launchApiServer(String baseUri, int port) async {
  await rand_serve.ready;

  final router = new Router(baseUri, new MisrouteController(), _definition);
  final server = await HttpServer.bind(InternetAddress.ANY_IP_V4, port);

  final sub = server.map(router.routeRequest).listen((Future res) async {
    try { await res; }
    catch (e, trace) {
      model.logger.severe('Uncaught throw during API request', e, trace);

      if (e is Error) {
        model.logger.severe('Throw was error; API shutting down');
        rethrow;
      }
    }
  });

  model.logger.info('API server launched');
  return sub;
}