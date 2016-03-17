part of model;

/// A class representing a party
class Party extends PartySharkEntity with IdentifiableMixin {
  //Data
  final int adminCode;
  final SettingsGroup settings;

  User player;
  bool __isPlaying = false;
  DateTime __lastRecomputed = new DateTime.now();

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

  DateTime get lastRecomputed => __lastRecomputed;

  void _recomputePlaylist() {
    __lastRecomputed = new DateTime.now();

    if (playlist.length < 3) { return; }

    Playthrough playing = playlist.first;

    playlist
      ..remove(playing)
      ..sort((a, b) => b.netVotes - a.netVotes)
      ..insert(0, playing);
  }
}