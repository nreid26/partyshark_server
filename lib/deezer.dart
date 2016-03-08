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

Future<Iterable<Song>> searchSongs(String query) async {
  try {
    HttpClientRequest req = (await _client.getUrl(_baseUri.replace(path: 'search', query: 'q=$query')))
        ..headers.contentType = ContentType.JSON;

    HttpClientResponse res = await req.close();
    Map<String, dynamic> body = JSON.decode(await UTF8.decodeStream(res));

    if (body.containsKey('error')) { return null; }

    return body['data'].map(_songFromMap).where((s) => s != null);
  }
  catch (e) {
    return null;
  }
}

Song _songFromMap(Map<String, dynamic> body) {
  try {
    int code = body['id'];
    if (code == null) { return null; }

    String title = body['title_short'];

    Map artist = body['artist'];
    String artistName = (artist == null) ? null : artist['name'];

    int year = null;
    try { year = DateTime.parse(body['release_date']).year; }
    catch (e) { }

    Duration duration = (body['duration'] is int) ? new Duration(seconds: body['duration']) : null;

    return new Song(code, title, artistName, year, duration);
  }
  catch (e) {
    return null;
  }
}