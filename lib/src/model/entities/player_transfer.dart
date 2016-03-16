part of model;

/// An enum representing the states of a player transfer
enum TransferStatus {
  Open,
  Closed
}

/// A class representing a request for transfer of player privilege
class PlayerTransfer extends PartySharkEntity with DeferredIdentifiableMixin {
  // Statics
  static const Duration lifetime = const Duration(minutes: 10);

  //Data
  final User requester;
  final DateTime creationTime = new DateTime.now();

  DateTime __closureTime;
  TransferStatus __status = TransferStatus.Open;

  //Constructor
  PlayerTransfer._(PartySharkModel model, int identity, this.requester) : super(model, identity);

  //Methods
  TransferStatus get status => __status;
  void           set status(TransferStatus t) {
    if (__status == TransferStatus.Closed) {  }
    else {
      __status ??= t;
      __closureTime = new DateTime.now();
    }
  }

  DateTime get closureTime => __closureTime;

  bool get hasExpired {
    DateTime now = new DateTime.now();

    switch (status) {
      case TransferStatus.Open:
        return now.difference(creationTime) > lifetime;
      case TransferStatus.Closed:
        return now.difference(closureTime) > lifetime;
      default:
        return true;
    }
  }
}