part of model;

/// A class representing a party
class Party extends PartySharkEntity with IdentifiableMixin {
  //Data
  final PartySharkModel __model;
  final int identity;
  final int adminCode;
  final SettingsGroup settings;

  User player;
  bool __isPlaying = false;
  DateTime __lastRetrieved = new DateTime.now();

  final List<Playthrough> playlist = [ ];
  final Set<User> users = new Set();
  final Set<PlayerTransfer> transfers = new Set();

  //Constructor
  Party._(PartySharkModel model, int identity, this.adminCode, this.settings) : super(model, identity);

  //Methods
  int get partyCode => identity;

  bool get isPaused => !isPlaying;
  void set isPaused(bool b) { if (b != null) { isPlaying = !b; } }

  bool get isPlaying => __isPlaying;
  void set isPlaying(bool b) { __isPlaying ??= b; }

  void _recomputePlaylist() {
    if (playlist.length < 3) { return; }

    Playthrough playing = playlist.first;

    playlist
      ..remove(playing)
      ..sort((a, b) => b.netVotes - a.netVotes)
      ..insert(0, playing);
  }
}