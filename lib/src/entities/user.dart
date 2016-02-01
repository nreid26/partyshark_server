part of entities;

///A class representing a user at a party
class User extends Object with Identifiable {
  //Data
  final String username;
  final Party party;
  bool isAdmin;

  //Constructor
  User(this.party, this.username, [this.isAdmin = false]);

  //Methods
  int get usercode => identity;
}