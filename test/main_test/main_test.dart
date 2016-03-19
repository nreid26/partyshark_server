import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:partyshark_server/src/controllers/controllers.dart';
import 'package:partyshark_server/src/messaging/messaging.dart';

part './extracted_functions.dart';
part './custom_matchers.dart';



main() async {

  group('The server', () {
    Process server;

    setUpAll(() async {
      server = await Process.start('dart C:/Users/Nick/Desktop/partyshark_server/bin/main.dart', ['$baseUri', '3000', '-l', '0', '-T']);
      server.stderr.pipe(stderr);
      server.stdout.pipe(stdout);
    });

    tearDownAll(() {
      server.stdin.writeln('exit');
      server.stdin.writeln();

      expect(server.exitCode, completion(equals(0)));
    });

    test('can create a party with a default user', () async {
      FullResponse<PartyMsg> p = await createParty();

      expect(p.body.code.value, isNonNegative);
      expect(p.body.adminCode.value, isNonNegative);
      expect(p.userCode, isNonNegative);
    });

    test('allows users to query thesleves', () async {
      FullResponse<PartyMsg> p = await createParty();
      FullResponse<UserMsg> u = await getSelf(p.body.code.value, p.userCode);

      expect(u.body.username.isDefined, isTrue);
      expect(u.body.username.value is String, isTrue);
    });

    test('assignes default admin/player on party creation', () async {
      FullResponse<PartyMsg> p = await createParty();
      FullResponse<UserMsg> u = await getSelf(p.body.code.value, p.userCode);

      expect(p.body.player.value, equals(u.body.username.value));
      expect(u.body.isAdmin.isDefined, isTrue);
      expect(u.body.isAdmin.value, isTrue);
    });

    test('can add users to a party', () async {
      FullResponse<PartyMsg> p = await createParty();
      FullResponse<UserMsg> u = await createUser(p.body.code.value);

      expect(u.body.username.value is String, isTrue);
      expect(u.userCode, isNonNegative);
      expect(u.userCode, isNot(equals(p.userCode)));
    });

    test('can promote users to admin', () async {
      FullResponse<PartyMsg> p = await createParty();
      FullResponse<UserMsg> u = await createUser(p.body.code.value);

      expect(u.body.isAdmin, isUndefinedOrValue(equals(false)));

      FullResponse<UserMsg> u_c2 = await promoteUser(p.body.code.value, u.userCode, null);
      expect(u_c2.body.isAdmin, isUndefinedOrValue(equals(false)));

      FullResponse<UserMsg> u_c3 = await promoteUser(p.body.code.value, u.userCode, p.body.adminCode.value);
      expect(u_c3.body.isAdmin.isDefined, equals(true));
      expect(u_c3.body.isAdmin.value, equals(true));
    });


  });


}

