part of controllers;

class PlaythroughController extends PartysharkController {
  PlaythroughController._(): super._();

  /// Veto a playthrough.
  @HttpHandler(HttpMethod.Delete)
  Future delete(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams);
    if (prep.hadError) { return; }

    Playthrough play = __getPlaythrough(req, pathParams, prep.party);
    if(play == null) { return; }

    __deletePlaythrough(play);
    __recomputePlaylist(play.party);
    _closeGoodRequest(req, null, null);

    model.logger.fine('Vetoed playthrough: ${play.identity} in party: ${prep.party.identity}');
  }

  /// Get a playthrough.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var play = __getPlaythrough(req, pathParams, prep.party);
    if(play == null) { return; }

    _respondWithPlaythrough(req, pathParams, play);

    model.logger.fine('Served playthrough: ${play.identity} in party: ${prep.party.identity}');
  }


  /// Update a playthrough.
  @HttpHandler(HttpMethod.Put)
  Future put(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false, getBodyAs: new PlaythroughMsg());
    if (prep.hadError) { return; }

    var play = __getPlaythrough(req, pathParams, prep.party);
    if (play == null) { return; }

    bool doRecompute = false, playDeleted = false;
    var msg = prep.body as PlaythroughMsg;

    /// Update completed duration.
    if (msg.completedDuration.isDefined) {
      _Failure potFail = new _Failure(HttpStatus.BAD_REQUEST, 'The completed duration of this playthrough could not be changed.', null);

      if (!prep.requester.isPlayer) { // Requester must be player
        _closeBadRequest(req, potFail..why = 'You are not the party player.');
        return;
      }
      else if(msg.completedDuration.value == null) {
        _closeBadRequest(req, potFail..why = 'The playthrough cannot have a null completed duration.');
        return;
      }
      else if (msg.completedDuration.value < play.completedDuration) { // Playthrough cannot rewind
        _closeBadRequest(req, potFail..why = 'The playthrough was already more complete than the submitted duration.');
        return;
      }

      play.completedDuration = msg.completedDuration.value;

      if (play.completedDuration >= play.song.duration) {
        __deletePlaythrough(play);
        doRecompute = true;
        playDeleted = true;

        model.logger.finer('Completed playthrough: ${play.identity} in party: ${prep.party.partyCode}');
      }
    }

    /// Change vote.
    if (msg.vote.isDefined && !playDeleted) {
      Ballot ballot = play.ballots.firstWhere((b) => b.voter == prep.requester, orElse: () => null);

      if (ballot != null && ballot.vote != msg.vote.value) {
        ballot.vote = msg.vote.value;
        doRecompute = true;
      }
      else if(ballot == null && msg.vote.value != null) {
        ballot = new Ballot(prep.requester, play, msg.vote.value);
        doRecompute = true;

        datastore.add(ballot);
        play.ballots.add(ballot); // MUST HAPPEN AFTER DATASTORE INSERTION
      }

      /// Enforce veto condition
      if (__playthroughHitVetoCondition(play)) {
        __deletePlaythrough(play);
        doRecompute = true;
        playDeleted = true;

        model.logger.finer('Vetoed playthrough: ${play.identity} in party: ${prep.party.partyCode} due to voting conditions');
      }
    }

    if (doRecompute) { __recomputePlaylist(play.party); }
    _respondWithPlaythrough(req, pathParams, play);

    model.logger.fine('Updated playthrough: ${play.identity} in party: ${prep.party.partyCode}');
  }

  void _respondWithPlaythrough(HttpRequest req, Map pathParams, Playthrough play) {
    _closeGoodRequest(req, recoverUri(pathParams), _playthroughToMsg(play).toJsonString());
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

    Playthrough play = datastore.playthroughs[code];
    if (play == null || !party.playthroughs.contains(play)) {
      _closeBadRequest(req, potFail..why = 'The supplied playthrough code does not exist.');
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

    datastore.ballots.removeAll(play.ballots);
    datastore.playthroughs.remove(play);
  }

  bool __playthroughHitVetoCondition(Playthrough play) =>
      play.downvotes / play.party.users.length >= play.party.settings.vetoRatio;
}