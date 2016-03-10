part of controllers;

class PlaythroughController extends PartysharkController {
  PlaythroughController._(): super._();

  /// Veto a playthrough.
  @HttpHandler(HttpMethod.Delete)
  Future delete(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    model.logger.fine('Serving ${HttpMethod.Delete} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams);
    if (prep.hadError) { return; }

    Playthrough play = __getPlaythrough(req, pathParams, prep.party);
    if(play == null) { return; }

    model.deletePlaythrough(play);
    _closeGoodRequest(req, null, null);
  }

  /// Get a playthrough.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    model.logger.fine('Serving ${HttpMethod.Get} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var play = __getPlaythrough(req, pathParams, prep.party);
    if(play == null) { return; }

    _closeGoodRequest(req, recoverUri(pathParams), _playthroughToMsg(play));
  }


  /// Update a playthrough.
  @HttpHandler(HttpMethod.Put)
  Future put(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    model.logger.fine('Serving ${HttpMethod.Put} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false, getBodyAs: new PlaythroughMsg());
    if (prep.hadError) { return; }

    var msg = prep.body as PlaythroughMsg;

    var play = __getPlaythrough(req, pathParams, prep.party);
    if (play == null) { return; }

    /// Update completed duration.
    if (msg.completedDuration.isDefined) {
      if (prep.requester.isPlayer == false) {
        const String what = 'The completed duration of this playthrough could not be changed.';
        const String why = 'You are not the party player.';
        _closeBadRequest(req, new _Failure(HttpStatus.BAD_REQUEST, what, why));
        return;
      }

      model.modifyEntity(play, () {
        play.completedDuration = msg.completedDuration.value;
      });
    }

    /// Change vote.
    if (msg.vote.isDefined) {
      model.voteOnPlaythrough(prep.requester, play, msg.vote.value);
    }

    _closeGoodRequest(req, recoverUri(pathParams), _playthroughToMsg(play));
  }

  PlaythroughMsg _playthroughToMsg(Playthrough p) {
    return new PlaythroughMsg()
      ..suggester.value = p.suggester.username
      ..completedDuration.value = p.completedDuration
      ..code.value = p.identity
      ..position.value = p.position
      ..songCode.value = p.song.identity
      ..creationTime.value = p.creationTime
      ..downvotes.value = p.downvotes
      ..upvotes.value = p.upotes
      ..vote.value = p.ballots.firstWhere((b) => b.voter == p.suggester, orElse: () => null)?.vote;
  }

  Playthrough __getPlaythrough(HttpRequest req, Map pathParams, Party party) {
    _Failure potFail = new _Failure(HttpStatus.NOT_FOUND, 'The playthrough could not be found.', null);

    int code = int.parse(pathParams[Key.PlaythroughCode], onError: (s) => null);
    if (code == null) {
      _closeBadRequest(req, potFail..why = 'The supplied playthrough code is malformed.');
      return null;
    }

    Playthrough play = model.getEntity(Playthrough, code);
    if (play == null || !party.playthroughs.contains(play)) {
      _closeBadRequest(req, potFail..why = 'The supplied playthrough code does not exist.');
      return null;
    }

    return play;
  }
}