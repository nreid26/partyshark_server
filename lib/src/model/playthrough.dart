part of model;

/// A class representing an instance of a song to be played at a party
class Playthrough extends PartysharkEntity with IdentifiableMixin {
  //Data
  double __completedRatio = 0.0;

  final Party party;
  final Song song;
  final User suggester;
  final DateTime creationTime = new DateTime.now();

  final Set<Ballot> ballots = new Set();

  //Constructor
  Playthrough._(PartysharkModel model, int identity, this.song, User suggester) : super(model, identity), suggester = suggester, party = suggester.party;

  //Methods
  int get upotes => ballots.where((Ballot b) => b.vote == Vote.Up).length;
  int get downvotes => ballots.where((Ballot b) => b.vote == Vote.Down).length;
  int get netVotes => upotes - downvotes;

  int get position => party.playlist.indexOf(this);

  double get completedRatio => __completedRatio;
  void   set completedRatio(double d) {
    if (d == null || d < __completedRatio) { return; }

    __completedRatio = d.clamp(0.0, 1.0);

    if (__completedRatio >= 1.0) { __model.deletePlaythrough(this); }
  }

  bool get _hitVetoCondition => downvotes > party.settings.vetoRatio * party.users.length;
}