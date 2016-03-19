part of main_test;

final Uri baseUri = Uri.parse('http://localhost:3000');
final HttpClient client = new HttpClient();

class FullResponse<T extends Jsonable> {
  final HttpClientResponse res;
  final T body;
  final int userCode;

  FullResponse.__(this.res, this.body, this.userCode);

  static Future<FullResponse> deferred(HttpClientRequest req, Jsonable msg) async {
    final res = await req.close();
    final body = msg..fillFromJsonString(await UTF8.decodeStream(res));

    final header = res.headers.value(Header.SetUserCode);
    final int userCode = (header == null) ? null : int.parse(header, onError: (s) => null);
    return new FullResponse.__(res, body, userCode);
  }
}


Future<FullResponse<PartyMsg>> createParty() async {
  var req = await client.postUrl(baseUri.replace(path: 'parties'));
  req.write('{ }');

  return FullResponse.deferred(req, new PartyMsg());
}

Future<FullResponse<UserMsg>> createUser(int partyCode) async {
  var req = await client.postUrl(baseUri.replace(path: 'parties/$partyCode/users'));
  req.write('{ }');

  return FullResponse.deferred(req, new UserMsg());
}

Future<FullResponse<UserMsg>> promoteUser(int partyCode, int userCode, int adminCode) async {
  UserMsg msg = new UserMsg()
      ..adminCode.value = adminCode
      ..adminCode.isDefined = true;

  var req = await client.putUrl(baseUri.replace(path: 'parties/$partyCode/users/self'));
  req
    ..headers.set(Header.UserCode, userCode)
    ..write(msg.toJsonString());

  return FullResponse.deferred(req, new UserMsg());
}

Future<FullResponse<UserMsg>> getSelf(int partyCode, int userCode) async {
  var req = await client.getUrl(baseUri.replace(path: 'parties/$partyCode/users/self'));
  req.headers.set(Header.UserCode, userCode);

  return FullResponse.deferred(req, new UserMsg());
}