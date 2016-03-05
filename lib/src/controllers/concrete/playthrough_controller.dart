part of controllers;

class PlaythroughController extends PartysharkController {
  PlaythroughController._(): super._();

  /// Veto a playthrough.
  @HttpHandler(HttpMethod.Delete)
  Future delete(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBody: false);
    if (prep.hadError) { return; }

    Playthrough play = __getPlaythrough(req, pathParams, prep.party);
    if(play == null) { return; }

    __deletePlaythrough(play);
    __recomputePlaylist(play.party);
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

    var play = __getPlaythrough(req, pathParams, prep.party);
    if (play == null) { return; }

    var msg = new PlaythroughMsg()..fillFromJsonMap(prep.body);

    /// Change vote.
    if (msg.vote.isDefined) {
      Ballot ballot = play.ballots.firstWhere((b) => b.voter == prep.requester, orElse: () => null);

      if (ballot != null) {
        ballot.vote = msg.vote.value;
      }
      else if(msg.vote.value != null) {
        ballot = new Ballot(prep.requester, play, msg.vote.value);
        play.ballots.add(ballot);
        model[Ballot].add(ballot);
      }

      /// Enforce veto condition
      if (__playthroughHitVetoCondition(play)) {
        __deletePlaythrough(play);
      }
    }

    /// Update completed duration.
    if (msg.completedDuration.isDefined && prep.requester.isPlayer && msg.completedDuration.value > play.completedDuration) {
      play.completedDuration = msg.completedDuration.value;

      if (play.completedDuration >= play.song.duration) {
        __deletePlaythrough(play);
      }
    }

    __recomputePlaylist(play.party);
    __respondWithPlaythrough(req, pathParams, prep, play);
  }


  void __respondWithPlaythrough(HttpRequest req, Map pathParams, _Preperation prep, Playthrough p) {
    var msg = new PlaythroughMsg()
        ..completedDuration.value = p.completedDuration
        ..code.value = p.identity
        ..position.value = p.position
        ..songCode.value = p.song.identity
        ..creationTime.value = p.creationTime
        ..downvotes.value = p.downvotes
        ..upvotes.value = p.upotes
        ..vote.value = p.ballots.firstWhere((b) => b.voter == prep.requester, orElse: () => null)?.vote;

    _closeGoodRequest(req, recoverUri(pathParams), msg.toJsonString());
  }

  Playthrough __getPlaythrough(HttpRequest req, Map pathParams, Party party) {
    int code = int.parse(pathParams[Key.PlaythroughCode], onError: (s) => null);
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

  void __recomputePlaylist(Party party) {
    List l = party.playthroughs.toList(growable: false)
      ..sort((a, b) => b.netVotes - a.netVotes);

    int i = 0;
    for(Playthrough p in l) {
      p.position = i++;
    }
  }

  void __deletePlaythrough(Playthrough play) {
    play.party.playthroughs.remove(play);
    model[Ballot].removeAll(play.ballots);
    model[Playthrough].remove(play);
  }

  bool __playthroughHitVetoCondition(Playthrough play) =>
      play.downvotes / play.party.users.length >= play.party.settings.vetoRatio;
}