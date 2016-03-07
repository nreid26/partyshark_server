part of entities;

/// A class representing a party
class Party extends Object with DeferredIdentifiableMixin {
  //Data
  final int adminCode;
  final SettingsGroup settings;
  User player;
  bool isPlaying = false;

  final Set<Playthrough> playthroughs = new HashSet();
  final Set<User> users = new HashSet();

  //Constructor
  Party(this.adminCode, this.settings);

  //Methods
  int get partyCode => identity;

  bool get isPaused => !isPlaying;
  void set isPaused(bool pause) { isPlaying = !pause; }
}