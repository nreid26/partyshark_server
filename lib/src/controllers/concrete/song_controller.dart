part of controllers;

class SongController extends PartysharkController {
  SongController._(): super._();

  /// Get a song.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Failure potFail = new _Failure(HttpStatus.NOT_FOUND, 'The requested song does not exist.', null);

    int songCode = int.parse(pathParams[Key.SongCode], onError: (s) => null);
    if (songCode == null) {
      _closeBadRequest(req, potFail..why = 'The provided song code is malformed.');
      return;
    }

    Song song = await _getSong(songCode);
    if (song == null) {
      _closeBadRequest(req, potFail..why = 'The provided song code is undefined.');
      return;
    }

    _closeGoodRequest(req, recoverUri(pathParams), _convertToSongMsg(song).toJsonString());

    logger.fine('Served song: $songCode');
  }

  SongMsg _convertToSongMsg(Song song) {
    return new SongMsg()
      ..code.value = song.identity
      ..artist.value = song.artist
      ..title.value = song.title
      ..duration.value = song.duration
      ..year.value = song.year;
  }

  Future<Song> _getSong(int songCode) async {
    Song song = datastore.songs[songCode];

    if (song == null) {
      logger.finer('Queried Deezer for song: $songCode');
      song = await deezer.getSong(songCode);

      if (song != null) {
        datastore.add(song);
      }
    }

    return song;
  }
}