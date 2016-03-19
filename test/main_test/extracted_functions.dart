part of main_test;

final Uri baseUri = Uri.parse('http://localhost:3000');
final HttpClient client = new HttpClient();


enum Vote { Up, Down }


class FullResponse<T> {
  final HttpClientResponse res;
  final T body;
  final int userCode;

  FullResponse.__(this.res, this.body, this.userCode);

  static Future<FullResponse> deferred(HttpClientRequest req, msg) async {
    final res = await req.close();

    final source = await UTF8.decodeStream(res);
    var body;
    if (msg is Jsonable) {
      body = msg..fillFromJsonString(source);
    }
    else if (msg is Function) {
      body = fillFromJsonGroupString(source, msg);
    }

    final header = res.headers.value(Header.SetUserCode);
    final int userCode = (header == null) ? null : int.parse(header, onError: (s) => null);
    return new FullResponse.__(res, body, userCode);
  }
}

void setUserCode(HttpClientRequest req, int userCode) {
  req.headers.set(Header.UserCode, userCode);
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
  setUserCode(req, userCode);
  req.write(msg.toJsonString());

  return FullResponse.deferred(req, new UserMsg());
}

Future<FullResponse<UserMsg>> getSelf(int partyCode, int userCode) async {
  var req = await client.getUrl(baseUri.replace(path: 'parties/$partyCode/users/self'));
  setUserCode(req, userCode);

  return FullResponse.deferred(req, new UserMsg());
}

Future<FullResponse<PartyMsg>> getParty(int partyCode, int userCode) async {
  var req = await client.getUrl(baseUri.replace(path: 'parties/$partyCode'));
  setUserCode(req, userCode);

  return FullResponse.deferred(req, new PartyMsg());
}

Future<FullResponse<PlaythroughMsg>> createPlaythrough(int partyCode, int userCode, int songCode) async {
  var req = await client.postUrl(baseUri.replace(path: 'parties/$partyCode/playlist'));
  setUserCode(req, userCode);
  req.write(new PlaythroughMsg()..songCode.value = songCode);

  return FullResponse.deferred(req, new PlaythroughMsg());
}

Future<FullResponse<PlaythroughMsg>> voteOnPlaythrough(int partyCode, int userCode, int playthroughCode, Vote vote) async {
  var req = await client.putUrl(baseUri.replace(path: 'parties/$partyCode/playlist/$playthroughCode'));
  setUserCode(req, userCode);

  var msg = new PlaythroughMsg()
      ..properties.forEach((p) => p.isDefined = false)
      ..vote.isDefined = true
      ..vote.encodableValue = vote?.index;
  req.write(msg);

  return FullResponse.deferred(req, new PlaythroughMsg());
}