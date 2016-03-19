import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

import 'package:partyshark_server/src/model/model.dart';
import 'package:partyshark_server/src/controllers/controllers.dart';
import 'package:partyshark_server/src/randomization_service/randomization_service.dart' as rand_serve;
import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/src/collector.dart';



Future main(List<String> allArgs) async {
  final ArgManager args = new ArgManager(allArgs);

  final Logger logger = prepareLogger(args.logLevel);
  final PartysharkModel model = new PartysharkModel(logger);

  final address = (args.isTesting) ? InternetAddress.LOOPBACK_IP_V4 : InternetAddress.ANY_IP_V4;
  final serverSub = await launchApiServer(model, args.baseUri, args.port, address);

  final Collector collector = new Collector(
      model,
      const Duration(hours: 1),
      const Duration(hours: 1),
      const Duration(minutes: 7)
  );

  listenOnStdin((line, sub) {
    if (line.toLowerCase() == 'exit') {
      sub.cancel();
      serverSub.cancel();
      collector.dispose();

      print('Sever shutdown');
      print('Hit enter to continue');
    }
  });
}

Logger prepareLogger(int levelIndex) {
  final log = new File('log.txt');

  if (log.existsSync()) {
    log.delete();
  }

  Logger.root
      ..level = Level.LEVELS[levelIndex]
      ..onRecord.listen((rec) {
        String message = '${rec.level} ${rec.message}';
        if (rec.error != null) { message += rec.error.toString(); }
        message += '\r\n';

        log.writeAsStringSync(message, mode: FileMode.APPEND);
      });

  return Logger.root;
}

void listenOnStdin(dynamic handler(String line, StreamSubscription sub)) {
  var sub;
  sub = stdin
      .transform(UTF8.decoder)
      .transform(new LineSplitter())
      .listen((line) { handler(line, sub); });
}

Future<StreamSubscription> launchApiServer(PartysharkModel model, String baseUri, int port, InternetAddress address) async {
  final ControllerSet set = new ControllerSet(model);

  final definition = {
    'parties': [set.parties, {
      Key.PartyCode: [set.party, {
        'playlist': [set.playlist, {
          Key.PlaythroughCode: set.playthrough
        }],
        'settings': set.settings,
        'users': [set.users, {
          'self': set.self,
          Key.Username: set.user
        }],
        'playertransfers': [set.transfers, {
          Key.PlayerTransferCode: set.transfer
        }]
      }],
    }]
  };

  rand_serve.logger = model.logger;
  await rand_serve.ready;

  final router = new Router(baseUri, new MisrouteController(), definition);
  final server = await HttpServer.bind(address, port);

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

class ArgManager {
  static const String __Logging = 'logging';
  static const __Testing = 'testing';

  static final ArgParser __parser = new ArgParser()
    ..addOption(__Logging, abbr: 'l')
    ..addFlag(__Testing, abbr: 'T');


  final List<String> __args;
  final ArgResults __argMap;

  ArgManager(List<String> args) :
        __args = args,
        __argMap = __parser.parse(args.skip(2).toList(growable: false));


  String get baseUri => __args[0];
  int get port => int.parse(__args[1]);
  int get logLevel => __argMap.wasParsed(__Logging) ? int.parse(__argMap[__Logging]) : 4;
  bool get isTesting => __argMap[__Testing];
}