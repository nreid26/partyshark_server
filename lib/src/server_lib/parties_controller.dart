part of server_lib;

class PartiesController extends PartysharkController {

  @HttpHandler(HttpMethod.Post)
  void post(HttpRequest req, [Map<PathParameterKey, dynamic> pathParams]) {
    SettingsGroup settings = new SettingsGroup();
    Party party = new Party(_RandService.adminCode, settings);
    User user = new User(party, _RandService.username, true);

    user.identity = _RandService.usercode;

    model
      ..add(settings)
      ..add(party)
      ..add(user);

    req.response
      ..statusCode = HttpStatus.OK
      ..headers.contentType = ContentType.JSON
      ..headers.add(_CustomHeader.SetUsercode, encodeBase64(user.identity))
      ..headers.set(_CustomHeader.Location, '')
      ..write(party)
      ..close();
  }
}