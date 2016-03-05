part of controllers;

/// A namespace class defining [String] constants naming HTTP headers
/// used by this library.
class Header {
  static const String
      SetUserCode = 'X-Set-User-Code',
      UserCode = 'X-User-Code',
      Location = 'Location',
      CrossOrigin = 'Access-Control-Allow-Origin';

  Header.__();
}

/// A namespace class defining [RouteKey] constants used by this library.
class Key {
  static final RouteKey
      PartyCode = new RouteKey(),
      Username = new RouteKey(),
      PlaythroughCode = new RouteKey(),
      TransferRequestCode = new RouteKey(),
      SongCode = new RouteKey();

  Key.__();
}

/// A namespace class defining [RouteController] constatnts from this library.
class Controller {
  static final PartyController Party = new PartyController._();
  static final PartiesController Parties = new PartiesController._();
  static final PlaylistController Playlist = new PlaylistController._();
  static final PlaythroughController Playthrough = new PlaythroughController._();
  static final SettingsController Settings = new SettingsController._();
  static final SongController Song = new SongController._();
  static final SongsController Songs = new SongsController._();
  static final UsersController Users = new UsersController._();

  Controller.__();
}

/// A message class holding data from successful precomputations.
class _Preperation {
  User requester, user;
  Party party;
  Map<String, dynamic> body;

  bool hadError = true;
}

/// A message class holding data needed to generate a failed HTTP response.
class _Failure {
  int status;
  String what, why;

  String toJsonString() => errorJson(what, why);

  _Failure(this.status, this.what, this.why);
}