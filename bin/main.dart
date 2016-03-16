import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:partyshark_server/src/model/model.dart' as model;

import './launch_server.dart';
import './arg_parsing.dart';


Future main(List<String> allArgs) async {
  final ArgManager args = new ArgManager(allArgs);

  prepareLogger(args.logLevel);

  final serverSub = await launchApiServer(args.baseUri, args.port);

  listenOnStdin((line, sub) {
    if (line.toLowerCase() == 'exit') {
      sub.cancel();
      serverSub.cancel();

      print('Sever shutdown');
      print('Hit enter to continue');
    }
  });
}

void prepareLogger(int levelIndex) {
  final log = new File('log.txt');

  if (log.existsSync()) {
    log.delete();
  }

  model.logger
      ..level = model.Level.LEVELS[levelIndex]
      ..onRecord.listen((rec) {
        String message = '${rec.level} ${rec.message}';
        if (rec.error != null) { message += rec.error.toString(); }
        message += '\r\n';

        log.writeAsStringSync(message, mode: FileMode.APPEND);
      });
}

void listenOnStdin(dynamic handler(String line, StreamSubscription sub)) {
  var sub;
  sub = stdin
      .transform(UTF8.decoder)
      .transform(new LineSplitter())
      .listen((line) { handler(line, sub); });
}
