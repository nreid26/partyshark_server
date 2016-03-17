part of model;

/// A class representing an instance of a song to be played at a party
class Playthrough extends PartySharkEntity with IdentifiableMixin {
  //Data
  Duration __completedDuration = const Duration();

  final Party party;
  final Song song;
  final User suggester;
  final DateTime creationTime = new DateTime.now();

  final Set<Ballot> ballots = new Set();

  //Constructor
  Playthrough._(PartySharkModel model, int identity, this.song, User suggester) : super(model, identity), suggester = suggester, party = suggester.party;

  //Methods
  int get upotes => ballots.where((Ballot b) => b.vote == Vote.Up).length;
  int get downvotes => ballots.where((Ballot b) => b.vote == Vote.Down).length;
  int get netVotes => upotes - downvotes;

  int get position => party.playlist.indexOf(this);

  Duration get completedDuration => __completedDuration;
  void     set completedDuration(Duration d) {
    if (d == null || __completedDuration > d) { return; }

    __completedDuration = d;

    if (__completedDuration >= song.duration) { __model.deletePlaythrough(this); }
  }

  bool get _hitVetoCondition => downvotes > party.settings.vetoRatio * party.users.length;
}