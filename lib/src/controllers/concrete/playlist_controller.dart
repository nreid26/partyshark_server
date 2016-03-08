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

    _closeGoodRequest(req, recoverUri(pathParams), toJsonGroupString(msgs));

    logger.fine('Served playlist for party: ${prep.party.partyCode}');
  }


  /// Suggest a playthrough.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new PlaythroughMsg(), checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = prep.body as PlaythroughMsg;

    Song song = await Controller.Song._getSong(msg.songCode.value);
    if (song == null) { return; }

    if (!__suggestionIsValid(req, prep)) { return; }

    Playthrough play = new Playthrough(song, prep.party.playthroughs.length, prep.requester);
    Ballot ballot = new Ballot(prep.requester, play, Vote.Up);

    datastore
        ..add(play)
        ..add(ballot);

    // MUST HAPPEN AFTER STORE INSERTION
    play.party.playthroughs.add(play);
    play.ballots.add(ballot);

    Map params = {Key.PlaythroughCode: play.identity, Key.PartyCode: prep.party};
    Controller.Playthrough._respondWithPlaythrough(req, params, play);

    logger.fine('Created new playthrough: ${play.identity} for party: ${prep.party.partyCode}');
  }


  bool __suggestionIsValid(HttpRequest req, _Preperation prep) {
    Party party = prep.party;
    if (party.settings.playthroughCap == null || party.playthroughs.length < party.settings.playthroughCap) {
      return true;
    }
    else {
      _closeBadRequest(req, new _Failure(HttpStatus.BAD_REQUEST, 'The playthrough suggestion could not be accepted.', 'The playlist is the maximum length allowed for this party.'));
      return false;
    }
  }
}