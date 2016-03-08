import 'dart:io';
import 'dart:async' show Future;

import 'package:partyshark_server/src/controllers/controllers.dart' as controllers show ready;

import 'package:partyshark_server/src/controllers/controllers.dart' hide ready;
import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/src/global.dart';


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

main(List<String> arguments) async {
  Set<String> options = collectOptions(arguments);
  prepareLogger(options);

  var server, router;

  try {
    await controllers.ready;

    router = new Router(arguments[0], new MisrouteController(), definition);
    server = await HttpServer.bind(InternetAddress.ANY_IP_V4, int.parse(arguments[1]));
  }
  catch (e, trace) {
    logger.severe('The PartyShark failed to launch!', e, trace);
    return;
  }

  logger.info('The PartyShark is swimming!');

  await for (Future res in server.map(router.routeRequest)) {
    try {
      await res;
    }
    catch (e, trace) {
      logger.severe('Uncaught exception during request handling.', e, trace);
      if (e is Error) { rethrow; } // Errors should crash the server
    }
  }

  logger.severe('The PartyShark died!');
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
  var level = Level.CONFIG;

  if (options.contains('v')) { level = Level.ALL; }
  else if (options.contains('c')) { }
  else if (options.contains('s')) { level = Level.OFF; }

  logger
      ..level = level
      ..onRecord.listen((rec) {
        print('${rec.level} ${rec.message}\n');
      });
}
