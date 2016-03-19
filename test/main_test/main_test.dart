import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:partyshark_server/src/controllers/controllers.dart';
import 'package:partyshark_server/src/messaging/messaging.dart';

part './misc.dart';

main() async {

  final Process server = await Process.start('dart ./bin/main.dart', ['$baseUri', '3000', '-l', '0', '-T']);
  server.stderr.transform(UTF8.decoder).transform(new LineSplitter()).listen(print);

  group('The server', () {
    test('can create a party', () async {
      FullResponse<PartyMsg> p = await createParty();

      expect(p.body.code.value, isNonNegative);
      expect(() => int.parse(p.res.headers.value(Header.SetUserCode)), returnsNormally);
    });

    test('can add users to a party', () async {
      FullResponse<PartyMsg> p = await createParty();
      FullResponse<UserMsg> u = await createUser(p.body.code.value);

      expect(u.body.username.value, new isInstanceOf<String>());
      expect(u.body.isAdmin.isDefined == false || u.body.isAdmin.value == false, isTrue);
      expect(() => int.parse(p.res.headers.value(Header.SetUserCode)), returnsNormally);
    });

  });


}

