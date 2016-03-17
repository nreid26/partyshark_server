part of model;

/// A class representing a user at a party
class User extends PartySharkEntity with IdentifiableMixin {
  //Data
  final String username;
  final Party party;

  bool isAdmin;
  DateTime _lastQueried = new DateTime.now();

  //Constructor
  User._(PartySharkModel model, int identity, this.party, this.username, [this.isAdmin = false]) : super(model, identity);

  //Methods
  int get userCode => identity;
  bool get isPlayer => party.player == this;

  DateTime get lastQueried => _lastQueried;
}