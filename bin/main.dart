import 'dart:io';
import 'dart:async' show Future;

import 'package:partyshark_server/src/controllers/controllers.dart';
import 'package:partyshark_server/src/randomization_service/randomization_service.dart' as rand_serve show ready;
import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/src/model/model.dart' as model;


var definition = {
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

main(List<String> arguments) async {
  Set<String> options = collectOptions(arguments);
  prepareLogger(options);

  var server, router;

  try {
    await rand_serve.ready;

    router = new Router(arguments[0], new MisrouteController(), definition);
    server = await HttpServer.bind(InternetAddress.ANY_IP_V4, int.parse(arguments[1]));
  }
  catch (e, trace) {
    model.logger.severe('The PartyShark failed to launch!', e, trace);
    return;
  }

  model.logger.shout('The PartyShark is swimming!');

  await for (Future res in server.map(router.routeRequest)) {
    try {
      await res;
    }
    catch (e, trace) {
      model.logger.severe('Uncaught exception during request handling: $e', e, trace);

      if (e is Error) {
        model.logger.severe('The PartyShark died!');
        rethrow;
      }
    }
  }

}

Set<String> collectOptions(List<String> args) {
  Pattern letters = new RegExp('([a-zA-Z])');

  return args
      .skip(2)
      .where((s) => s[0] == '-')
      .expand((s) => letters.allMatches(s))
      .map((Match m) => m.group(0))
      .toSet();
}

void prepareLogger(Set<String> options) {
  var level = model.Level.INFO;

  if (options.contains('v')) { level = model.Level.ALL; }
  else if (options.contains('c')) { level = model.Level.CONFIG; }
  else if (options.contains('s')) { level = model.Level.OFF; }

  model.logger
      ..level = level
      ..onRecord.listen((rec) {
        print('${rec.level} ${rec.message}\n');
      });
}
