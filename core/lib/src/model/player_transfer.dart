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

  DateTime __closureTime;
  TransferStatus __status = TransferStatus.Open;

  //Constructor
  PlayerTransfer._(PartysharkModel model, int identity, this.requester) : super(model, identity);

  //Methods
  TransferStatus get status => __status;
  void           set status(TransferStatus t) {
    if (__status == TransferStatus.Closed || t == null) {  }
    else {
      __status = t;
      __closureTime = new DateTime.now();

      requester.party.player = requester;
    }
  }

  DateTime get closureTime => __closureTime;
}