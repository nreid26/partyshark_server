part of controllers;

class SettingsController extends PartysharkController {
  SettingsController._(): super._();

  /// Handle CORS preflight.
  @HttpHandler(HttpMethod.Options)
  void options(HttpRequest req, Map<RouteKey, String> pathParams) {
    super.options(req, pathParams);
  }

  /// Get a settings group.
  @HttpHandler(HttpMethod.Get)
  Future get(HttpRequest req, Map<RouteKey, String> pathParams) async {
    model.logger.fine('Serving ${HttpMethod.Get} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, checkRequesterAdmin: false);
    if (prep.hadError) { return; }

    __respondWithSettings(req, pathParams, prep);
  }

  /// Update a settings group.
  @HttpHandler(HttpMethod.Put)
  Future put(HttpRequest req, [Map<RouteKey, String> pathParams]) async {
    model.logger.fine('Serving ${HttpMethod.Put} on ${recoverUri(pathParams)}');

    _Preperation prep = await _prepareRequest(req, pathParams, getBodyAs: new SettingsMsg());
    if (prep.hadError) { return; }

    SettingsGroup s = prep.party.settings;

    var msg = prep.body as SettingsMsg;

    model.modifyEntity(s, () {
      if (msg.virtualDj.isDefined) {
        s.usingVirtualDj = msg.virtualDj.value;
      }
      if (msg.userCap.isDefined) {
        s.userCap = msg.userCap.value;
      }
      if (msg.playthroughCap.isDefined) {
        s.playthroughCap = msg.playthroughCap.value;
      }
      if (msg.defaultGenre.isDefined) {
        s.defaultGenre = msg.defaultGenre.value;
      }
      if (msg.vetoRatio.isDefined) {
        s.vetoRatio = msg.vetoRatio.value;
      }
    });

    __respondWithSettings(req, pathParams, prep);
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