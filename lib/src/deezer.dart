library deezer;

import 'dart:io';
import 'dart:convert' show UTF8, JSON;
import 'dart:async' show Future;

import 'package:partyshark_server/src/messaging/messaging.dart' show SongMsg;
export 'package:partyshark_server/src/messaging/messaging.dart' show SongMsg;

final HttpClient _client = new HttpClient();
final Uri _baseUri = Uri.parse('https://api.deezer.com');


Future<SongMsg> getSong(int songId) async {
  final SongMsg msg = new SongMsg();

  try {
    HttpClientRequest req = (await _client.getUrl(_baseUri.replace(path: 'track/$songId')))
        ..headers.contentType = ContentType.JSON;

    HttpClientResponse res = await req.close();
    Map<String, dynamic> body = JSON.decode(await UTF8.decodeStream(res));

    if (body.containsKey('error')) { return null; }

    return new SongMsg()
        ..code.encodableValue = body['id']
        ..duration.value = new Duration(seconds: body['duration'].toInt());
  }
  catch (e) {
    msg
        ..code.isDefined = false
        ..duration.isDefined = false;
  }

  return msg;
}
