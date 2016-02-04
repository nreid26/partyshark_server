part of controllers;

class PartyController extends PartysharkController {

  PartyController.__internal();
  static final PartyController only = new PartyController.__internal();

  @HttpHandler(HttpMethod.Put)
  void put(HttpRequest req, [Map<PathParameterKey, String> pathParams]) {
    Party party = getParty(pathParams[PathKey.PartyCode], req);
    if(party == null) { return; }

    User user = getUserFromHeader(req);
    if(user == null) { return; }

    if (
      isMember(party, user, req) &&
      isAdmin(user, req)
    ) {
      //TODO: Delete the party
    }
  }
}