part of controllers;

class SettingsController extends PartysharkController {
  SettingsController._(): super._();

  /// Get a settings group.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    __respondWithSettings(req, pathParams, prep);

    logger.fine('Served settings for party: ${prep.party.partyCode}');
  }

  /// Update a settings group.
  @HttpHandler(HttpMethod.Put)
  Future put(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new SettingsMsg());
    if (prep.hadError) { return; }

    SettingsGroup s = prep.party.settings;

    var msg = prep.body as SettingsMsg;
    if(msg.virtualDj.isDefined && msg.virtualDj.value != null) {
      s.usingVirtualDj = msg.virtualDj.value;
    }
    if(msg.userCap.isDefined) {
      s.userCap = msg.userCap.value;
    }
    if(msg.playthroughCap.isDefined) {
      s.playthroughCap = msg.playthroughCap.value;
    }
    if(msg.defaultGenre.isDefined) {
      s.defaultGenre = msg.defaultGenre.value;
    }
    if(msg.vetoRatio.isDefined && msg.vetoRatio.value != null) {
      s.vetoRatio = msg.vetoRatio.value.clamp(0.01, 1.0);
    }

    __respondWithSettings(req, pathParams, prep);

    logger.fine('Updated settings for party: ${prep.party.partyCode}');
  }

  void __respondWithSettings(HttpRequest req, Map pathParams, _Preperation prep) {
    SettingsGroup s = prep.party.settings;

    var msg = new SettingsMsg()
        ..defaultGenre.value = s.defaultGenre
        ..vetoRatio.value = s.vetoRatio
        ..playthroughCap.value = s.playthroughCap
        ..userCap.value = s.userCap
        ..virtualDj.value = s.usingVirtualDj;

    _closeGoodRequest(req, recoverUri(pathParams), msg.toJsonString());
  }
}