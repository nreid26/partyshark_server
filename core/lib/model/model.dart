/// A library defining an object oriented model of a PartyShark API server instance.
///
/// This library defines entity classes and the [PartySharkModel] class and is
/// responsible for maintaining data integrity.
library model;

import 'dart:async' show Future;

import 'package:logging/logging.dart';

import 'package:partyshark_server_support/pseudobase/pseudobase.dart';
import 'package:partyshark_server_core/randomization_service/randomization_service.dart' as rand_serve;
import 'package:partyshark_server_core/deezer.dart' as deezer;

part './party.dart';
part './user.dart';
part './settings_group.dart';
part './song.dart';
part './playthrough.dart';
part './ballot.dart';
part './player_transfer.dart';


/// A base class provided members and getters common to all entity objects in the model.
abstract class PartySharkEntity {
  final PartySharkModel __model;
  final int identity;

  Logger get logger => __model.logger;

  PartySharkEntity(this.__model, this.identity);
}

/// An object oriented representation of a PartyShark API server.
///
/// This class provides methods for managing the lifecycle of the various model
/// entities, specifically creation and deletion.
class PartySharkModel {

  /// An indicator of the readiness of all model instances.
  ///
  /// This class partially depends on asynchronously loaded resources and thus
  /// is not guaranteed to function correctly until this [Future] is complete.
  static Future get ready => rand_serve.ready;

  /// The datastore for this model.
  final Datastore _datastore = new Datastore(const [Ballot, Party, PlayerTransfer, Playthrough, SettingsGroup, Song, User]);

  /// The [Logger] used by this model and its owned entities.
  final Logger logger;

  /// A basic generative constructor supporting [Logger] dependency injection.
  PartySharkModel(this.logger);



  /// Get a [PartySharkEntity] out of this by type and identity.
  ///
  /// If the entity should be retrieved asynchronously, because the model may
  /// be incomplete, set [useAsync] = true. In this case, if no cached entity
  /// is available and am asynchronous lookup method is, that method will be invoked
  /// and its [Future] returned; the result will also be cached internally. Regardless,
  /// a [Future] will be returned.
  dynamic getEntity(Type type, int identity, {bool useAsync: false}) {
    var syncRet = _datastore[type][identity];

    if (useAsync) {
      if (syncRet != null) {
        _prepareRetrievedEntity(syncRet);
        return new Future.value(syncRet);
      }

      return (() async {
        var temp;

        switch (type) {
          case Song:
            temp = await _createSong(identity); break;
          default:
            temp = null; break;
        }

        return _prepareRetrievedEntity(temp);
      })();
    }
    else {
      _prepareRetrievedEntity(syncRet);
      return syncRet;
    }
  }



  /// Get an [Iterable] of [PartySharkEntity] objects out of this by predicate.
  Iterable<dynamic> getEntites(Type type, [bool predicate(dynamic item)]) {
    return _datastore[type]
        .where(predicate ?? (item) => true)
        .map(_prepareRetrievedEntity);
  }

  /// Prepare entity object for retrieval.
  dynamic _prepareRetrievedEntity(dynamic entity) {
    if (entity is User) {
      (entity as User)._lastQueried = new DateTime.now();
    }

    return entity;
  }

  /// Create or modify a [Ballot] on a specified [Playthrough] to indicate a
  /// user [Vote].
  void voteOnPlaythrough(User voter, Playthrough play, Vote vote) {
    Ballot ballot = play.ballots.firstWhere((b) => b.voter == voter, orElse: () => null);

    // There is no existing Ballot and there is a Vote
    if (ballot == null && vote != null) {
      ballot = new Ballot._(this, _datastore[Ballot].freeIdentity, voter, play, vote);

      _datastore.add(ballot);
      play.ballots.add(ballot);

      _recomputePlaylist(play.party);

    }
    // There is an existing Ballot and its Vote is different
    else if (ballot != null && ballot.vote != vote) {
      ballot.vote = vote;

      _recomputePlaylist(play.party);
    }
  }


  /// Create a new [User] in a [Party] and manage all internal reference assignments.
  User createUser(Party party, [bool isAdmin = false]) {
    if (!_canAddUser(party)) { return null; };

    int identity = rand_serve.userCode;
    while (_datastore[User].containsIdentity(identity)) { identity++; }

    String username;
    int maxAttempts = 10;
    Set<String> takenNames = party.users.map((u) => u.username).toSet();

    do {
      username = rand_serve.username;
    } while (maxAttempts-- > 0 && takenNames.contains(username));

    if (maxAttempts == 0) {
      throw new Exception('Could not generate a unique username for party: ${party.partyCode}');
    }

    User ret = new User._(this, identity, party, username, isAdmin);
    _datastore.add(ret);
    party.users.add(ret);
    return ret;
  }

  /// Remove a [User] from this model and clean up all invalidated references.
  ///
  /// If the specified [User] is the last member of their [Party], the party will
  /// also be disposed.
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

    _recomputePlaylist(user.party);
  }

  /// Create and link a new [Party] in this model as well as a default admin [User].
  Party createParty() {
    int identity = rand_serve.partyCode;
    while (_datastore[Party].containsIdentity(identity)) { identity++; }

    // Make and store new objects
    SettingsGroup settings = new SettingsGroup._(this, _datastore[SettingsGroup].freeIdentity);
    Party party = new Party._(this, identity, rand_serve.adminCode, settings);
    User user = createUser(party, true);

    _datastore
      ..add(settings)
      ..add(party);

    party.player = user;
    settings._party = party;

    return party;
  }

  /// Remove a [Party] and all its associated entities from this model.
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

  /// Create an link a [Playthrough] in this model assigned to a specified [Party].
  Playthrough createPlaythrough(Song song, User suggester) {
    final Party party = suggester.party;

    if (!_canAddPlaythrough(party)) { return null; }

    Playthrough play = new Playthrough._(this, _datastore[Playthrough].freeIdentity, song, suggester);
    Ballot ballot = new Ballot._(this, _datastore[Ballot].freeIdentity, suggester, play, Vote.Up);

    _datastore
      ..add(play)
      ..add(ballot);

    play
      ..party.playlist.add(play)
      ..ballots.add(ballot);

    _recomputePlaylist(party);

    return play;
  }

  /// Remove and unlink a [Playthrough].
  void deletePlaythrough(Playthrough play) {
    play.party.playlist.remove(play);

    _datastore[Ballot].removeAll(play.ballots);
    _datastore[Playthrough].remove(play);

    _recomputePlaylist(play.party);
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

  Future<Song> _createSong(int songCode) async {
    deezer.SongMsg msg = await deezer.getSong(songCode);

    if (msg == null || !msg.code.isDefined || msg.code.value != songCode) {
      return null;
    }
    else {
      Song ret = new Song._(this, songCode);
      _datastore.add(ret);
      return ret;
    }
  }

  /// Calculate and sort the [Playthrough] entities assigned to the specified
  /// [Party] according to the requsite ordering rules.
  void _recomputePlaylist(Party party) {
    if (party.playlist.isEmpty) { return; }

    int pred(Playthrough a, Playthrough b) {
      int x = b.netVotes - a.netVotes;
      if (x != 0) { return x; }
      else { return a.creationTime.difference(b.creationTime).inMilliseconds; }
    }

    party._lastRecomputed = new DateTime.now();
    Playthrough playing = party.playlist.first;

    party.playlist
        .where(_hitVetoCondition)
        .toList(growable: false)
        .forEach(deletePlaythrough);

    if (party.playlist.contains(playing)) {
      party.playlist
        ..remove(playing)
        ..sort(pred)
        ..insert(0, playing);
    }
    else {
      party.playlist.sort(pred);
    }
  }

  /// Returns true if the specified [Playthrough] should be vetoed based on its
  /// state within the model; false otherwise.
  bool _hitVetoCondition(Playthrough play) => play.downvotes > play.party.settings.vetoRatio * play.party.users.length;

  /// Returns true if it is valid to add a [Playthrough] to the provided party;
  /// returns false otherwise.
  bool _canAddPlaythrough(Party party) =>
      party.settings.playthroughCap == null || party.playlist.length < party.settings.playthroughCap;

  /// Returns true if it is valid to add a [User] to the provided party;
  /// returns false otherwise.
  bool _canAddUser(Party party) =>
      party.settings.userCap == null || party.users.length < party.settings.userCap;
}





