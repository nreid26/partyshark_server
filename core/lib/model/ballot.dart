part of model;

/// An enum representing the possible votes on a ballot
enum Vote {
  Up, Down
}

/// A class representing a ballot cast by a user on a playthrough
class Ballot extends PartySharkEntity with IdentifiableMixin {
  //Data
  final User voter;
  final Playthrough playthrough;

  Vote vote;

  //Constructor
  Ballot._(PartySharkModel model, int identity, this.voter, this.playthrough, this.vote) : super(model, identity);
}