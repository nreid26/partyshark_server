part of controllers;

class PartyController extends PartysharkController {

  PartyController.__(): super._();
  static final PartyController only = new PartyController.__();

  @HttpHandler(HttpMethod.Put)
  void put(HttpRequest req, [Map<RouteKey, String> pathParams]) {
    _PrepMsg rep = _prepareRequest(req, pathParams,
        getParty: true,
        getRequestingUser: true,
        checkRequestingUserIsAdmin: true
    );
  }
}