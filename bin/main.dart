import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

import 'package:partyshark_server/src/model/model.dart';
import 'package:partyshark_server/src/controllers/controllers.dart';
import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/src/collector.dart';



Future main(List<String> allArgs) async {
  final ArgManager args = new ArgManager(allArgs);

  final Logger logger = prepareLogger(args.verbosity, args.logFileName, args.usingConsole);

  await PartysharkModel.ready;
  logger.info('Model resources loaded');
  final PartysharkModel model = new PartysharkModel(logger);

  final address = (args.isLocal) ? InternetAddress.LOOPBACK_IP_V4 : InternetAddress.ANY_IP_V4;
  final serverSub = await launchApiServer(model, args.basePublicUrl, args.port, address);

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
      collector.cancel();

      logger.info('Sever shutdown');
      print('Sever shutdown');
      print('Hit enter to continue');
    }
  });
}

Logger prepareLogger(int levelIndex, String logFileName, bool usingConsole) {
  final Logger logger = Logger.root
    ..level = Level.LEVELS[levelIndex];

  String buildMessage(LogRecord rec) =>
      '${rec.level} ${rec.time} ${rec.message} \r\n';

  if (logFileName != null) {
    final log = new File(logFileName);

    if (log.existsSync()) {
      log.delete();
    }

    logger.onRecord.listen((rec) {
        String line = buildMessage(rec);
        log.writeAsStringSync(line, mode: FileMode.APPEND);
    });
  }

  if (usingConsole) {
    logger.onRecord.listen((rec) {
        String line = buildMessage(rec);

        if (rec.error != null || rec.stackTrace != null) {
          stderr.write(line);
          stderr.addError(rec.error, rec.stackTrace);
        }
        else  {
          stdout.write(line);
        }
    });
  }

  return logger;
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

  model.logger.info('API server launched on ${address.address}:$port');
  return sub;
}

class ArgManager {
  static const String __File = 'log';
  static const String __Verbosity = 'verbosity';
  static const String __Local = 'public';
  static const String __Console = 'console';

  static final ArgParser __parser = new ArgParser()
    ..addOption(__File, abbr: 'f')
    ..addOption(__Verbosity, abbr: 'v')
    ..addFlag(__Console, abbr: 'c')
    ..addFlag(__Local, abbr: 'l');

  final List<String> __args;
  final ArgResults __argMap;

  ArgManager(List<String> args) :
        __args = args,
        __argMap = __parser.parse(args.skip(2).toList(growable: false));


  String get basePublicUrl => __args[0];
  int get port => int.parse(__args[1]);

  int get verbosity => __argMap.wasParsed(__Verbosity) ? int.parse(__argMap[__Verbosity]) : 4;
  String get logFileName => __argMap[__File];
  bool get isLocal => __argMap[__Local];
  bool get usingConsole => __argMap[__Console];
}