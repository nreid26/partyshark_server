import 'package:partyshark_server/src/model/model.dart' as model;

import './launch_server.dart';


void main(List<String> args) {
  final int logIndex = args.indexOf('-l');
  prepareLogger((logIndex >= 0) ? int.parse(args[logIndex + 1]) : 4);

  launchApiServer(args[0], int.parse(args[1]));

}


void prepareLogger(int levelIndex) {
  model.logger
      ..level = model.Level.LEVELS[levelIndex]
      ..onRecord.listen((rec) {
        String message = '${rec.level} ${rec.message}';
        if (rec.error != null) { message += rec.error.toString(); }
        message += '\n';

        print(message);
      });
}
