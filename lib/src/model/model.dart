library model;

import 'dart:async' show Future;

import 'package:logging/logging.dart';
import 'package:partyshark_server/pseudobase/pseudobase.dart';
import 'package:partyshark_server/src/entities/entities.dart';
import 'package:partyshark_server/src/randomization_service/randomization_service.dart' as rand_serve;
import 'package:partyshark_server/deezer.dart' as deezer;

export 'package:logging/logging.dart';

part './public.dart';
part './private.dart';


final Datastore _datastore = new Datastore(const [Ballot, Party, PlayerTransfer, Playthrough, SettingsGroup, Song, User]);

Logger get logger => Logger.root;



typedef Future<T> AsyncGetter<T>(int identity);
dynamic getEntity(Type type, int identity, {useAsync: false}) {
  const Map<Type, AsyncGetter> asyncBackups = const {
    Song: _getSong
  };

  Table table = _datastore[type];
  var syncRet = (table == null) ? null : table[identity];

  if (useAsync) {
    if (syncRet == null) {
      Function backup = asyncBackups[type];
      if (backup != null) { return backup(identity); }
    }

    return new Future.value(syncRet);
  }

  return syncRet;
}

typedef void IntegrityEnforcer<T>(T item, void callback());
void modifyEntity(entity, void modify()) {
  const Map<Type, IntegrityEnforcer> enforcers = const {
    Party: _modifyParty,
    Playthrough: _modifyPlaythrough,
    PlayerTransfer: _modifyTransfer,
    SettingsGroup: _modifySettings,
    User: _modifyUser
  };

  IntegrityEnforcer enf = enforcers[entity.runtimeType];
  if (enf != null) { enf(entity, modify); }
  else { modify(); }
}