part of entities;

class Party extends Object with Identifiable {
  //Data
  final int identity, adminCode;
  final OptionGroup options = new OptionGroup();
  User player;

  //Constructor
  Party(this.identity, this.adminCode);
}