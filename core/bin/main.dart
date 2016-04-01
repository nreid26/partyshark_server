import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

import 'package:partyshark_server_core/model/model.dart';
import 'package:partyshark_server_core/controllers/controllers.dart';
import 'package:partyshark_server_support/signpost/signpost.dart';
import 'package:partyshark_server_core/collector.dart';



Future main(List<String> allArgs) async {
  final ArgManager args = new ArgManager(allArgs);

  final Logger logger = prepareLogger(args.verbosity, args.logFileName, args.usingConsole);

  await PartySharkModel.ready;
  logger.info('Model resources loaded');
  final PartySharkModel model = new PartySharkModel(logger);

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


/// Retrieves and configures the [Logger] instance injected throughout the
/// core API server libraries.
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


/// Opens an asynchronous, line based, reader on stdin and directs its output
/// at the supplied callback.
void listenOnStdin(dynamic handler(String line, StreamSubscription sub)) {
  var sub;
  sub = stdin
      .transform(UTF8.decoder)
      .transform(new LineSplitter())
      .listen((line) { handler(line, sub); });
}


/// Constructs a [signpost] [Router] with controllers from a [ControllerSet]
/// and then registers it to listen on an [HttpServer].
Future<StreamSubscription> launchApiServer(PartySharkModel model, String baseUri, int port, InternetAddress address) async {
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

/// A convenience class wrapping an [ArgParser] providing a convenient place to
/// define parser rules and getters for type-converted values.
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