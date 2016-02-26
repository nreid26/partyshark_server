part of messaging;

@dartson.Entity()
class PartyMsg {
}

@dartson.Entity()
class PlyerTransferMsg {
}

@dartson.Entity()
class PlaythroughMsg {
}

@dartson.Entity()
class SettingsMsg {
}

@dartson.Entity()
class UserMsg {
}

@dartson.Entity()
class SongMsg {
  int code, year;
  Uri stream_location;
  Duration duration;
  String title, artist;
}