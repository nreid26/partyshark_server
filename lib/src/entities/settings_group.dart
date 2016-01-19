part of entities;

///An enum representing a basic musical genre
enum Genre {
  Rock,
  Metal,
  Jazz,
  Country,
  Pop,
  Classical,
  Folk,
  Electronic
}

///A class representing the settings on a party
class SettingsGroup extends Object with Identifiable {
  //Data
  final int identity;
  final Party party;
  bool usingVirtualDj = false;
  Genre defaultGenre = null;
  int userCap = -1, playthroughCap = -1;

  //Constructor
  SettingsGroup(this.identity, this.party);

  //Methods
  bool get hasDefaultGenre => defaultGenre != null;
}