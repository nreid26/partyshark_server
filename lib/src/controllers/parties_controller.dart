part of controllers;

class PartiesController extends PartysharkController {

  PartiesController.__(): super._();
  static final only = new PartiesController.__();

  @HttpHandler(HttpMethod.Post)
  void post(HttpRequest req, [Map<RouteKey, dynamic> pathParams]) {
    SettingsGroup settings = new SettingsGroup();
    Party party = new Party(rand_serve.adminCode, settings);
    User user = new User(party, rand_serve.username, true);

    user.identity = rand_serve.usercode;

    model
      ..add(settings)
      ..add(party)
      ..add(user);

    req.response
      ..statusCode = HttpStatus.OK
      ..headers.contentType = ContentType.JSON
      ..headers.add(CustomHeader.SetUserCode, encodeBase64(user.identity))
      ..headers.set(
          CustomHeader.Location,
          PartyController.only.recoverUri({
            PathKey.PartyCode: party.identity
          })
      )
      ..write(party)
      ..close();
  }
}