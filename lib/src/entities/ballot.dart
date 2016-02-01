part of entities;

///An enum representing the possible votes on a ballot
enum Vote {
  Up, Down
}

///A class representing a ballot cast by a user on a playthrough
class Ballot extends Object with Identifiable {
  //Data
  Vote vote;
  final User voter;
  final Playthrough playthrough;

  //Constructor
  Ballot(this.voter, this.playthrough, this.vote);
}