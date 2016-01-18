part of entities;

class User extends Object with Identifiable {
  //Data
  final int identity;
  final String username;
  final Party party;
  bool isAdmin;

  //Constructor
  User(this.identity, this.party, this.username, [bool isAdmin = false]) {
    this.isAdmin = isAdmin;
  }
}