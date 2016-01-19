part of entities;

///A class representing a party
class Party extends Object with Identifiable {
  //Data
  final int identity, adminCode;
  final SettingsGroup options = new SettingsGroup();
  User player;
  bool isPlaying = false;

  final Set<Playthrough> playthroughs = new HashSet();
  final Set<User> users = new HashSet();

  //Constructor
  Party(this.identity, this.adminCode);

  //Methods
  int get partycode => identity;

  bool get isPaused => !isPlaying;
  void set isPaused(bool pause) { isPlaying = !pause; }
}