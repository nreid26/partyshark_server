part of controllers;

class PlaythroughController extends PartysharkController {
  PlaythroughController._(): super._();

  /// Veto a playthrough.
  @HttpHandler(HttpMethod.Delete)
  Future delete(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBody: false);
    if (prep.hadError) { return; }

    var play = __getPlaythrough(req, pathParams, prep.party);
    if(play == null) { return; }

    prep.party.playthroughs.remove(play);
    play.ballots.forEach(model[Ballot].remove);
    model[Playthrough].remove(play);

    __recomputePlaylist();
    _closeGoodRequest(req, null, null);
  }

  /// Get a playthrough.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBody: false, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var play = __getPlaythrough(req, pathParams, prep.party);
    if(play == null) { return; }

    __respondWithPlaythrough(req, pathParams, prep, play);
  }


  /// Update a playthrough.
  @HttpHandler(HttpMethod.Put)
  Future put(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = new PlaythroughMsg()..fillFromJsonMap(prep.body);
    var play = __getPlaythrough(req, pathParams, prep.party);
    if (play == null) { return; }

    if (msg.completed.isDefined && prep.requester.isPlayer && msg.completed.value > play.completedDuration) {
      play.completedDuration = msg.completed.value;
    }

    if (msg.vote.isDefined) {
      Ballot ballot = play.ballots.fold(null, (a, b) => (b.voter == prep.requester) ? b : a);
      if (ballot != null) {
        ballot.vote = msg.vote.value;
      }
      else if(msg.vote.value != null) {
        ballot = new Ballot(prep.requester, play, msg.vote.value);
        play.ballots.add(ballot);
        model[Ballot].add(ballot);
      }
    }

    __recomputePlaylist();
    __respondWithPlaythrough(req, pathParams, prep, play);
  }


  void __respondWithPlaythrough(HttpRequest req, Map pathParams, _Preperation prep, Playthrough p) {
    var msg = new PlaythroughMsg()
        ..completed.value = p.completedDuration
        ..code.value = p.identity
        ..position.value = p.position
        ..songCode.value = p.song.identity
        ..creationTime.value = p.creationTime
        ..downvotes.value = p.downvotes
        ..upvotes.value = p.upotes
        ..vote.value = p.ballots.singleWhere((b) => b.voter == prep.requester).vote;

    _closeGoodRequest(req, recoverUri(pathParams), msg.toJsonString());
  }

  Playthrough __getPlaythrough(HttpRequest req, Map pathParams, Party party) {
    int code = int.parse(pathParams[CustomKey.PlaythroughCode], onError: (s) => null);
    if (code == null) {
      _closeBadRequest(req, new _Failure(HttpStatus.NOT_FOUND, 'The playthrough could not be found', 'The supplied playthrough code is malformed'));
      return null;
    }

    Playthrough play = model[Playthrough][code];
    if (play == null || !party.playthroughs.contains(play)) {
      _closeBadRequest(req, new _Failure(HttpStatus.NOT_FOUND, 'The playthrough could not be found', 'The supplied playthrough code does not exist'));
      return null;
    }

    return play;
  }

  void __recomputePlaylist() {

  }
}