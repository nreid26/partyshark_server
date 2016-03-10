part of controllers;

class PlaylistController extends PartysharkController {
  PlaylistController._(): super._();

  /// Get a playlist.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    Iterable<PlaythroughMsg> msgs = prep.party.playthroughs
          .map(Controller.Playthrough._playthroughToMsg)
          ..forEach((PlaythroughMsg p) => p.completedDuration.isDefined = false);

    _closeGoodRequest(req, recoverUri(pathParams), msgs);

    model.logger.fine('Served playlist for party: ${prep.party.partyCode}');
  }


  /// Suggest a playthrough.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new PlaythroughMsg(), checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = prep.body as PlaythroughMsg;
    var fail = new _Failure(HttpStatus.BAD_REQUEST, 'The suggested playthrough was rejected.', null);

    Song song = await model.getSong(msg.songCode.value);
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
    Controller.Playthrough._respondWithPlaythrough(req, params, play);

    model.logger.fine('Created new playthrough: ${play.identity} for party: ${prep.party.partyCode}');
  }
}