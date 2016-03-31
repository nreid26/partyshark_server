part of model;

/// An enum representing the states of a player transfer
enum TransferStatus {
  Open,
  Closed
}

/// A class representing a request for transfer of player privilege
class PlayerTransfer extends PartysharkEntity with DeferredIdentifiableMixin {
  //Data
  final User requester;
  final DateTime creationTime = new DateTime.now();

  DateTime _closureTime;
  TransferStatus _status = TransferStatus.Open;

  //Constructor
  PlayerTransfer._(PartysharkModel model, int identity, this.requester) : super(model, identity);

  //Methods
  TransferStatus get status => _status;

  DateTime get closureTime => _closureTime;
}