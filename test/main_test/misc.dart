part of main_test;

final Uri baseUri = Uri.parse('http://localhost:3000');
final HttpClient client = new HttpClient();

class FullResponse<T extends Jsonable> {
  final HttpClientResponse res;
  final T body;

  FullResponse.__(this.res, this.body);

  static Future<FullResponse> deferred(HttpClientRequest req, Jsonable msg) async {
    final res = await req.close();
    final body = msg..fillFromJsonString(await UTF8.decodeStream(res));
    return new FullResponse.__(res, body);
  }
}


Future<FullResponse> createParty() async {
  var req = await client.postUrl(baseUri.replace(path: 'parties'));
  req.write('{ }');

  return FullResponse.deferred(req, new PartyMsg());
}

Future<FullResponse> createUser(int partCode) async {
  var req = await client.postUrl(baseUri.replace(path: 'parties/$partCode/users'));
  req.write('{ }');

  return FullResponse.deferred(req, new UserMsg());
}