part of controllers;

class PlaylistController extends PartysharkController {
  PlaylistController._(): super._();

  /// Get a playlist.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBody: false, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    __respondWithPlaylist(req, pathParams, prep);
  }


  /// Suggest a playthrough.
  @HttpHandler(HttpMethod.Post)
  Future post(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    var msg = new PlaythroughMsg()..fillFromJsonMap(prep.body);
    var playthrough = new Playthrough(model[Song][msg.songCode], prep.party.playthroughs.length, prep.user);
    var ballot = new Ballot(prep.user, playthrough, Vote.Up);

    prep.party.playthroughs.add(playthrough);
    playthrough.ballots.add(ballot);

    model
        ..add(playthrough)
        ..add(ballot);

    __respondWithPlaylist(req, pathParams, prep);
  }

  void __respondWithPlaylist(HttpRequest req, Map pathParams, _Preperation prep) {
    Iterable<PlaythroughMsg> getMessages() sync* {
      for(Playthrough p in prep.party.playthroughs) {
        yield new PlaythroughMsg()
          ..completed.isDefined = false
          ..code.value = p.identity
          ..position.value = p.position
          ..songCode.value = p.song.identity
          ..creationTime.value = p.creationTime
          ..downvotes.value = p.downvotes
          ..upvotes.value = p.upotes
          ..vote.value = p.ballots.fold(null, (a, b) => (b.voter == prep.requester) ? b : a)?.vote;
      }
    }

    _closeGoodRequest(req, recoverUri(pathParams), toJsonGroupString(getMessages()));
  }
}