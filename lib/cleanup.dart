library cleanup;

import 'dart:async';

import 'package:partyshark_server/src/model/model.dart';

launchCleanup() {

  const Duration transferLife = const Duration(minutes: 10);
  final Timer transferTimer = new Timer.periodic(transferLife, (Timer t) {
    model.getEntites(PlayerTransfer, (PlayerTransfer trans) {
      final DateTime when = (trans.status == TransferStatus.Closed) ? trans.closureTime : trans.creationTime;

      return new DateTime.now().difference(when) > transferLife;
    });
  });
}
