part of controllers;

class PlaylistController extends PartysharkController with PlaythroughMessenger {
  PlaylistController._(): super._();

  /// Get a playlist.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    model.logger.fine('Serving ${HttpMethod.Get} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    Iterable<PlaythroughMsg> msgs = prep.party.playlist.map(playthroughToMsg)
          ..forEach((PlaythroughMsg p) => p.completedDuration.isDefined = false);

    _closeGoodRequest(req, recoverUri(pathParams), msgs);
  }


  /// Suggest a playthrough.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    model.logger.fine('Serving ${HttpMethod.Post} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new PlaythroughMsg(), checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = prep.body as PlaythroughMsg;
    var fail = new _Failure(HttpStatus.BAD_REQUEST, 'The suggested playthrough was rejected.', null);

    Song song = await model.getEntity(Song, msg.songCode.value, useAsync: true);
    if (song == null) {
      _closeBadRequest(req, fail..why = 'The sugested song does not exist or is unavailable.');
      return;
    }

    Playthrough play = model.createPlaythrough(song, prep.party, prep.requester);
    if (song == null) {
      _closeBadRequest(req, fail..why = 'The suggestion violated party settings.');
      return;
    }

    Map params = {Key.PlaythroughCode: play.identity, Key.PartyCode: prep.party};
    _closeGoodRequest(req, Controller.Playthrough.recoverUri(params), playthroughToMsg(play));
  }
}