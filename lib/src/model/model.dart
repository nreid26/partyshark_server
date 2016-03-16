library model;

import 'dart:async' show Future;

import 'package:partyshark_server/pseudobase/pseudobase.dart';
import 'package:partyshark_server/src/randomization_service/randomization_service.dart' as rand_serve;
import 'package:partyshark_server/src/deezer.dart' as deezer;


part './public.dart';
part './private.dart';

part './entities/party.dart';
part './entities/user.dart';
part './entities/settings_group.dart';
part './entities/song.dart';
part './entities/playthrough.dart';
part './entities/ballot.dart';
part './entities/player_transfer.dart';


typedef Future<T> AsyncGetter<T>(int identity);

abstract class PartySharkEntity {
  final PartySharkModel __model;
  final int identity;

  PartySharkEntity(this.__model, this.identity);
}

class PartySharkModel {
  /// The datastore for this model
  final Datastore _datastore = new Datastore(const [Ballot, Party, PlayerTransfer, Playthrough, SettingsGroup, Song, User]);


  /// Get an [Entity] out of this by type and identity.
  dynamic getEntity(Type type, int identity, {bool useAsync: false}) {
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


  /// Get an [Iterable] of [Entity] objects out of this by predicate.
  Iterable<dynamic> getEntites(Type type, [bool predicate(dynamic item)]) =>
      _datastore[type].where(predicate ?? (item) => true);


  void voteOnPlaythrough(User voter, Playthrough play, Vote vote) {
    bool recompute = true;
    Ballot ballot = play.ballots.firstWhere((b) => b.voter == voter, orElse: () => null);

    // There is no existing Ballot and there is a Vote
    if (ballot == null && vote != null) {
      ballot = new Ballot._(this, _datastore[Ballot].freeIdentity, voter, play, vote);

      _datastore.add(ballot);
      play.ballots.add(ballot);
    }
    // There is an existing Ballot and its Vote is different
    else if (ballot != null && ballot.vote != vote) {
      ballot.vote = vote;
    }
    else {
      recompute = false;
    }

    // Enforce veto condition
    if (play._hitVetoCondition) {
      deletePlaythrough(play);
      recompute = false;
    }

    if (recompute) {
      play.party._recomputePlaylist();
    }
  }


  User createUser(Party party, [bool isAdmin = false]) {
    if (party.settings.userCap == null) { }
    else if (party.users.length < party.settings.userCap) { }
    else { return null; };

    int identity = rand_serve.userCode;
    while (_datastore[User].containsIdentity(identity)) { identity++; }

    String username;
    int maxAttempts = 10;
    Set<String> takenNames = party.users.map((u) => u.username).toSet();

    do {
      username = rand_serve.username;
    } while (maxAttempts-- > 0 && takenNames.contains(username));

    if (maxAttempts == 0) { throw new Exception('Could not generate a unique username for party: ${party.partyCode}'); }

    return new User._(this, identity, party, username, isAdmin);
  }

  void deleteUser(User user) {
    _datastore.remove(user);
    user.party.users.remove(user);

    if (user.party.users.length == 0) {
      deleteParty(user.party);
      return;
    }

    user.party.transfers
        .where((t) => t.requester == user)
        .toList(growable: false)
        .forEach(deleteTransfer);

    if (user.party.player == user) {
      user.party.player = null;
    }
  }


  Party createParty() {
    // Make and store new objects
    SettingsGroup settings = new SettingsGroup._(this, _datastore[SettingsGroup].freeIdentity);
    Party party = new Party._(this, _datastore[Party].freeIdentity, rand_serve.adminCode, settings);
    User user = createUser(party, true);

    _datastore
      ..add(settings)
      ..add(party);

    party.player = user;
    settings._party = party;

    return party;
  }

  void deleteParty(Party party) {
    _datastore[Party].remove(party);
    _datastore[User].removeAll(party.users);
    _datastore[SettingsGroup].remove(party.settings);
    _datastore[PlayerTransfer].removeAll(party.transfers);

    party.playlist.forEach((play) {
      _datastore[Ballot].removeAll(play.ballots);
      _datastore[Playthrough].remove(play);
    });
  }


  Playthrough createPlaythrough(Song song, User suggester) {
    final Party party = suggester.party;

    if (party.settings.playthroughCap == null ||
        party.playlist.length < party.settings.playthroughCap)
    { }
    else { return null; }

    Playthrough play = new Playthrough._(this, _datastore[Playthrough].freeIdentity, song, suggester);
    Ballot ballot = new Ballot._(this, _datastore[Ballot].freeIdentity, suggester, play, Vote.Up);

    _datastore
      ..add(play)
      ..add(ballot);

    return play
      ..party.playlist.add(play)
      ..ballots.add(ballot);
  }

  void deletePlaythrough(Playthrough play) {
    play.party.playlist.remove(play);

    _datastore[Ballot].removeAll(play.ballots);
    _datastore[Playthrough].remove(play);
  }


  PlayerTransfer createTransfer(User user) {
    PlayerTransfer trans = _datastore[PlayerTransfer]
        .firstWhere((PlayerTransfer t) => t.requester == user, orElse: () => null);

    if (trans != null) { return trans; }

    trans = new PlayerTransfer._(this, _datastore[PlayerTransfer].freeIdentity, user);
    _datastore.add(trans);
    user.party.transfers.add(trans);

    return trans;
  }

  void deleteTransfer(PlayerTransfer trans) {
    _datastore.remove(trans);
    trans.requester.party.transfers.remove(trans);
  }
}





