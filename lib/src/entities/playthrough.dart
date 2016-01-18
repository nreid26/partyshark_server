part of entities;

class Playthrough extends Object with Identifiable {
  //Data
  final int identity;
  int position;
  Duration completed = const Duration();
  final Song song;
  final User suggester;
  final Set<User> positiveVoters = new HashSet<User>(),
                  NegativeVoters = new HashSet<User>();

  //Constructor
  Playthrough(this.identity, this.position, this.suggester);

  //Methods
  int get positiveVotes => positiveVoters.length;
  int get negativeVotes => negativeVoters.length;
}