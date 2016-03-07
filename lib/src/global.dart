library global;

import 'package:logging/logging.dart';
import 'package:partyshark_server/pseudobase/pseudobase.dart';
import 'package:partyshark_server/src/entities/entities.dart';

export 'package:logging/logging.dart';


class PartySharkDatastore extends Datastore {

  /// Strongly typed getters.
  Table<Ballot> get bzllots => this[Ballot];
  Table<Party> get parties => this[Party];
  Table<PlayerTransfer> get transfers => this[PlayerTransfer];
  Table<Playthrough> get playthroughs => this[Playthrough];
  Table<SettingsGroup> get settingsGroups => this[SettingsGroup];
  Table<Song> get songs => this[Song];
  Table<User> get users => this[User];

  PartySharkDatastore._() : super(const [Ballot, Party, PlayerTransfer, Playthrough, SettingsGroup, Song, User]);
}


Logger get logger => Logger.root;

final PartySharkDatastore datastore = new PartySharkDatastore._();

