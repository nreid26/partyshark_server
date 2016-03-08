part of entities;

/// A class representing a user at a party
class User extends Object with IdentifiableMixin {
  //Data
  final int identity;
  final String username;
  final Party party;
  bool isAdmin;

  //Constructor
  User(this.identity, this.party, this.username, [this.isAdmin = false, int i]);

  //Methods
  int get userCode => identity;
  bool get isPlayer => party.player == this;
}