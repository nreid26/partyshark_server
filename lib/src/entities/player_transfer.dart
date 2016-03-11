part of entities;

/// An enum representing the states of a player transfer
enum TransferStatus {
  Open,
  Closed
}

/// A class representing a request for transfer of player privilege
class PlayerTransfer extends Object with DeferredIdentifiableMixin {
  //Data
  final User requester;
  final DateTime creationTime = new DateTime.now();
  DateTime closureTime;
  TransferStatus status = TransferStatus.Open;

  //Constructor
  PlayerTransfer(this.requester);
}