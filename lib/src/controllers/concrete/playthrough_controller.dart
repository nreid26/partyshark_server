part of controllers;

class PlaythroughController extends PartysharkController with PlaythroughMessenger {
  PlaythroughController._(): super._();

  /// Handle CORS preflight.
  @HttpHandler(HttpMethod.Options)
  void options(HttpRequest req, Map<RouteKey, String> pathParams) {
    super.options(req, pathParams);
  }

  /// Veto a playthrough.
  @HttpHandler(HttpMethod.Delete)
  Future delete(HttpRequest req, Map<RouteKey, String> pathParams) async {
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
  Future get(HttpRequest req, Map<RouteKey, String> pathParams) async {
    model.logger.fine('Serving ${HttpMethod.Get} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var play = __getPlaythrough(req, pathParams, prep.party);
    if(play == null) { return; }

    _closeGoodRequest(req, recoverUri(pathParams), playthroughToMsg(play));
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

      play.completedDuration = msg.completedDuration.value;
    }

    /// Change vote.
    if (msg.vote.isDefined) {
      model.voteOnPlaythrough(prep.requester, play, msg.vote.value);
    }

    _closeGoodRequest(req, recoverUri(pathParams), playthroughToMsg(play));
  }

  Playthrough __getPlaythrough(HttpRequest req, Map pathParams, Party party) {
    _Failure potFail = new _Failure(HttpStatus.NOT_FOUND, 'The playthrough could not be found.', null);

    int code = int.parse(pathParams[Key.PlaythroughCode], onError: (s) => null);
    if (code == null) {
      _closeBadRequest(req, potFail..why = 'The supplied playthrough code is malformed.');
      return null;
    }

    Playthrough play = model.getEntity(Playthrough, code);
    if (play == null || !party.playlist.contains(play)) {
      _closeBadRequest(req, potFail..why = 'The supplied playthrough code does not exist.');
      return null;
    }

    return play;
  }
}