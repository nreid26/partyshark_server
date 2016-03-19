import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:partyshark_server/src/controllers/controllers.dart';
import 'package:partyshark_server/src/messaging/messaging.dart';

part './misc.dart';

main() async {

  group('The server', () {
    Process server;

    setUpAll(() async {
      server = await Process.start('dart C:/Users/Nick/Desktop/partyshark_server/bin/main.dart', ['$baseUri', '3000', '-l', '0', '-T']);
      server.stderr.transform(UTF8.decoder).transform(new LineSplitter()).listen(stderr.add);
    });

    test('can create a party', () async {
      FullResponse<PartyMsg> p = await createParty();

      expect(p.body.code.value, isNonNegative);
      expect(p.body.adminCode.value, isNonNegative);
      expect(() => int.parse(p.res.headers.value(Header.SetUserCode)), returnsNormally);
    });

    test('can add users to a party', () async {
      FullResponse<PartyMsg> p = await createParty();
      FullResponse<UserMsg> u = await createUser(p.body.code.value);

      expect(u.body.username.value is String, isTrue);
      expect(() => int.parse(p.res.headers.value(Header.SetUserCode)), returnsNormally);
    });

    test('can promote users to admin', () async {
      FullResponse<PartyMsg> p = await createParty();
      FullResponse<UserMsg> u1 = await createUser(p.body.code.value);

      expect(u1.body.isAdmin.isDefined == false || u1.body.isAdmin.value == false, isTrue);

      int userCode = int.parse(p.res.headers.value(Header.SetUserCode));

      FullResponse<UserMsg> u2 = await promoteUser(p.body.code.value, userCode, null);
      expect(u2.body.isAdmin.isDefined == false || u2.body.isAdmin.value != true, isTrue);

      FullResponse<UserMsg> u3 = await promoteUser(p.body.code.value, userCode, p.body.adminCode.value);
      expect(u3.body.isAdmin.isDefined == true && u3.body.isAdmin.value == true, isTrue);
    });

    tearDownAll(() {
      server.stdin.writeln('exit');
      server.stdin.writeln();

      expect(server.exitCode, completion(equals(0)));
    });

  });


}

