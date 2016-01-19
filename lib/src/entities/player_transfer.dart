part of entities;

///An enum representing the states of a player transfer
enum TransferStatus {
  Open,
  Closed
}

///A class representing a request for transfer of player privilege
class PlayerTransfer extends Object with Identifiable {
  //Data
  final int identity;
  final User requester;
  final DateTime creationTime = new DateTime.now();
  TransferStatus status = TransferStatus.Open;

  //Constructor
  PlayerTransfer(this.identity, this.requester);
}