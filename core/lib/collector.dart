/// A library implementing stale entity collection of the API server.
///
/// The functions and classes defined within represent a specialised client for
/// a [PartySharkModel] instance intended to detect and delete stale entities from
/// that model using the same methods available to normal clients.
library cleanup;

import 'dart:async';

import 'package:partyshark_server_core/model/model.dart';


/// A class implementing the entire required functionality of this library.
class Collector {
  /// The model this [Collector] collects on
  final PartySharkModel model;

  /// The lifetime this [Collector] allows a [PlayerTransfer].
  final Duration transferLifetime;

  /// The lifetime this [Collector] allows a [Party].
  final Duration partyLifetime;

  /// The lifetime this [Collector] allows a [User].
  final Duration userLifetime;

  List<Timer> __timers;

  /// The generative constructor of a [Collector] which initialized periodic
  /// collection of entities in [model].
  Collector(this.model, this.partyLifetime, this.userLifetime, this.transferLifetime) {

    __timers = [
      new Timer.periodic(partyLifetime, (t) => collectParties()),
      new Timer.periodic(userLifetime, (t) => collectUsers()),
      new Timer.periodic(transferLifetime, (t) => collectTransfers()),
    ];

  }

  /// Collect the stale [Party] instances in [model].
  ///
  /// This is the same function this [Collector] periodically calls internally.
  void collectParties() {
    final DateTime now = new DateTime.now();

    model.logger.info('Collecting expired parties');

    model
        .getEntites(Party, (Party p) => now.difference(p.lastRecomputed) > partyLifetime)
        .toList(growable: false)
        .forEach(model.deleteParty);
  }

  /// Collect the stale [PlayerTransfer] instances in [model].
  ///
  /// This is the same function this [Collector] periodically calls internally.
  void collectTransfers() {
    final DateTime now = new DateTime.now();

    bool transPredicate(PlayerTransfer trans) {
      switch (trans.status) {
        case TransferStatus.Closed:
          return now.difference(trans.closureTime) > transferLifetime;
        case TransferStatus.Open:
          return now.difference(trans.creationTime) > transferLifetime;
        default:
          return true;
      }
    }

    model.logger.info('Collecting expired player transfers');

    model
        .getEntites(PlayerTransfer, transPredicate)
        .toList(growable: false)
        .forEach(model.deleteTransfer);
  }


  /// Collect the stale [User] instances in [model].
  ///
  /// This is the same function this [Collector] periodically calls internally.
  void collectUsers() {
    final DateTime now = new DateTime.now();

    model.logger.info('Collecting expired users');

    model
        .getEntites(User, (User u) => now.difference(u.lastQueried) > userLifetime)
        .toList(growable: false)
        .forEach(model.deleteUser);
  }

  /// Permanently and gracefully halt the operation of this object.
  void cancel() {
    model.logger.info('Collection cancelled');
    __timers.forEach((t) => t.cancel());
  }
}