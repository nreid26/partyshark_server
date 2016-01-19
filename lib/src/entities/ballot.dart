part of entities;

///An enum representing the possible votes on a ballot
enum Vote {
  Up, Down
}

///A class representing a ballot cast by a user on a playthrough
class Ballot extends Object with Identifiable {
  //Data
  final int identity;
  Vote vote;
  final User voter;
  final Playthrough playthrough;

  //Constructor
  Ballot(this.identity, this.voter, this.playthrough, this.vote);
}