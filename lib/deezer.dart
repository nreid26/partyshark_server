library deezer;

import 'dart:io';
import 'dart:convert' show UTF8, JSON;
import 'dart:async' show Future;

import 'package:partyshark_server/src/entities/entities.dart';

final HttpClient _client = new HttpClient();
final Uri _baseUri = Uri.parse('https://api.deezer.com');


Future<Song> getSong(int songId) async {
  try {
    HttpClientRequest req = (await _client.getUrl(_baseUri.replace(path: 'track/$songId')))
        ..headers.contentType = ContentType.JSON;

    HttpClientResponse res = await req.close();
    Map<String, dynamic> body = JSON.decode(await UTF8.decodeStream(res));

    if (body.containsKey('error')) { return null; }

    return _songFromMap(body);
  }
  catch (e) {
    return null;
  }
}


Song _songFromMap(Map<String, dynamic> body) {
    int code = body['id'];
    if (code == null) { return null; }

    Duration duration;
    if (body['duration'] is num) {
      duration = new Duration(seconds: body['duration'].toInt());
    }
    else { return null; }

    return new Song(code, duration);
}