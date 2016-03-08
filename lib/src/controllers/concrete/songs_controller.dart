part of controllers;

class SongsController extends PartysharkController {
  SongsController._(): super._();

  /// Get a song.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    String query = req.uri.queryParameters['search'];

    _Failure potFail = new _Failure(HttpStatus.NOT_FOUND, 'The requested songs do not exist.', null);

    if (query == null) {
      _closeBadRequest(req, potFail..why = 'No search query was provided.');
      return;
    }

    Iterable<Song> songs = await deezer.searchSongs(query);
    if (songs == null) {
      _closeBadRequest(req, potFail..why = 'The provided search was malformed.');
      return;
    }

    datastore.songs.addAll(songs);

    Iterable<SongMsg> msgs = songs.map(Controller.Song._convertToSongMsg);
    _closeGoodRequest(req, null, toJsonGroupString(msgs));

    logger.fine('Served songs for search: $query');
  }
}