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
    Song song = await Controller.Song._getSong(msg.songCode.value);
    if (song == null) { return; }

    if (!__suggestionIsValid(req, prep)) { return; }

    Playthrough play = new Playthrough(song, prep.party.playthroughs.length, prep.user);
    Ballot ballot = new Ballot(prep.user, play, Vote.Up);

    play.party.playthroughs.add(play);
    play.ballots.add(ballot);

    model
        ..add(play)
        ..add(ballot);

    __respondWithPlaylist(req, pathParams, prep);
  }

  void __respondWithPlaylist(HttpRequest req, Map pathParams, _Preperation prep) {
    Iterable<PlaythroughMsg> getMessages() sync* {
      for(Playthrough p in prep.party.playthroughs) {
        yield new PlaythroughMsg()
          ..completedDuration.isDefined = false
          ..code.value = p.identity
          ..position.value = p.position
          ..songCode.value = p.song.identity
          ..creationTime.value = p.creationTime
          ..downvotes.value = p.downvotes
          ..upvotes.value = p.upotes
          ..vote.value = p.ballots.firstWhere((b) => b.voter == prep.requester, orElse: () => null)?.vote;
      }
    }

    _closeGoodRequest(req, recoverUri(pathParams), toJsonGroupString(getMessages()));
  }

  bool __suggestionIsValid(HttpRequest req, _Preperation prep) {
    Party party = prep.party;
    if (party.settings.playthroughCap == null || party.playthroughs.length < party.settings.playthroughCap) {
      return true;
    }
    else {
      _closeBadRequest(req, new _Failure(HttpStatus.BAD_REQUEST, 'The playthrough suggestion could not be accepted', 'The playlist is the maximum length allowed for this party'));
      return false;
    }
  }
}