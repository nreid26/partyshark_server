part of entities;

/// A class representing an instance of a song to be played at a party
class Playthrough extends DeferredIdentifiable with IdentifiableMixin {
  //Data
  int position;
  Duration completedDuration = const Duration();
  final Song song;
  final User suggester;
  final DateTime creationTime = new DateTime.now();

  final Set<Ballot> ballots = new HashSet();

  //Constructor
  Playthrough(this.song, this.position, this.suggester);

  //Methods
  int get upotes => ballots.where((Ballot b) => b.vote == Vote.Up).length;
  int get downvotes => ballots.where((Ballot b) => b.vote == Vote.Down).length;
}