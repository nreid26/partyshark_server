/// A library representing the Deezer music ReST API for limited, stateless
/// interactions.
///
/// Only the functionality required internally by the PartyShark API server is
/// implemented and this library is free to depend on other core server libraries.
/// The primary purpose is to provide an abstracted interface to the API in native
/// dart code.
library deezer;

import 'dart:io';
import 'dart:convert' show UTF8, JSON;
import 'dart:async' show Future;

import 'package:partyshark_server_core/messaging/messaging.dart' show SongMsg;
export 'package:partyshark_server_core/messaging/messaging.dart' show SongMsg;


final HttpClient _client = new HttpClient();
final Uri _baseUri = Uri.parse('https://api.deezer.com');


/// A function for querying a song (track) by identity.
///
/// Only the information relevant to a [PartySharkModel] is returned. A failed
/// call will complete with a null message.
Future<SongMsg> getSong(int songId) async {
  final SongMsg msg = new SongMsg();

  try {
    HttpClientRequest req = (await _client.getUrl(_baseUri.replace(path: 'track/$songId')))
        ..headers.contentType = ContentType.JSON;

    HttpClientResponse res = await req.close();
    Map<String, dynamic> body = JSON.decode(await UTF8.decodeStream(res));

    if (body.containsKey('error')) { return null; }

    return new SongMsg()
        ..code.encodableValue = body['id'];
  }
  catch (e) {
    return null;
  }

  return msg;
}
