part of controllers;

class PartiesController extends PartysharkController {

  PartiesController.__internal();
  static final only = new PartiesController.__internal();

  @HttpHandler(HttpMethod.Post)
  void post(HttpRequest req, [Map<PathParameterKey, dynamic> pathParams]) {
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
      ..headers.add(_CustomHeader.SetUserCode, encodeBase64(user.identity))
      ..headers.set(
          _CustomHeader.Location,
          PartyController.only.recoverUri({
            PathKey.PartyCode: party.identity
          })
      )
      ..write(party)
      ..close();
  }
}