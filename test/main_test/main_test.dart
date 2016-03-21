library main_test;

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
      server = await Process.start('dart C:/Users/Nick/Desktop/partyshark_server/bin/main.dart $baseUri 3000 -cl -v 0', []);
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

      expect(p.body.code, isDefinedAndValue(isNonNegative));
      expect(p.body.adminCode, isDefinedAndValue(isNonNegative));
      expect(p.userCode, isNonNegative);
    });

    test('allows users to query thesleves', () async {
      FullResponse<PartyMsg> p = await createParty();
      FullResponse<UserMsg> u = await getSelf(p.body.code.value, p.userCode);

      expect(u.body.username, isDefinedAndValue(new isInstanceOf<String>()));
    });

    test('assignes default admin/player on party creation', () async {
      FullResponse<PartyMsg> p = await createParty();
      FullResponse<UserMsg> u = await getSelf(p.body.code.value, p.userCode);

      expect(p.body.player.value, equals(u.body.username.value));
      expect(u.body.isAdmin, isDefinedAndValue(isTrue));
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

      expect(u.body.isAdmin, isUndefinedOrValue(isFalse));

      FullResponse<UserMsg> u_c2 = await promoteUser(p.body.code.value, u.userCode, null);
      expect(u_c2.body.isAdmin, isUndefinedOrValue(equals(false)));

      FullResponse<UserMsg> u_c3 = await promoteUser(p.body.code.value, u.userCode, p.body.adminCode.value);
      expect(u_c3.body.isAdmin, isDefinedAndValue(isTrue));
    });

    test('allows users to query their party', () async {
      FullResponse<PartyMsg> p = await createParty();
      FullResponse<PartyMsg> p_c1 = await getParty(p.body.code.value, p.userCode);

      expect(p.body.code.value, equals(p_c1.body.code.value));
    });

    test('allows users to submit playthroughs with default upvote', () async {
      final int songCode = 95945830;

      FullResponse<PartyMsg> p = await createParty();
      FullResponse<UserMsg> u = await createUser(p.body.code.value);

      for (int i = 0; i < 3; i++) {
        FullResponse<PlaythroughMsg> pt = await createPlaythrough(p.body.code.value, u.userCode, songCode);

        expect(pt.body.code, isDefinedAndValue(isNonNegative));
        expect(pt.body.songCode, isDefinedAndValue(equals(songCode)));
        expect(pt.body.upvotes, isDefinedAndValue(equals(1)));
        expect(pt.body.downvotes, isDefinedAndValue(equals(0)));
        expect(pt.body.vote.encodableValue, equals(Vote.Up.index));
      }
    });

    test('allows users to vote on playthroughs', () async {
      final int songCode = 95945830;

      FullResponse<PartyMsg> p = await createParty();
      int partyCode = p.body.code.value;

      List<Future<FullResponse<UserMsg>>> fus = new List.generate(3, (i) => createUser(p.body.code.value));
      List<FullResponse<UserMsg>> us = [ ];
      for (var f in fus) { us.add(await f); }

      FullResponse<PlaythroughMsg> pt = await createPlaythrough(partyCode, us[0].userCode, songCode);
      /*
      List<Future<FullResponse<PlaythroughMsg>>> fps = new List.generate(3, (i) => createPlaythrough(partyCode, us[i].userCode, songCode));
      List<FullResponse<PlaythroughMsg>> ps = [ ];
      for (var p in fps) { ps.add(await p); }
      */

      FullResponse<PlaythroughMsg> pt_copy;
      pt_copy = await voteOnPlaythrough(partyCode, us[0].userCode, pt.body.code.value, Vote.Up);
      expect(pt_copy.body.vote.encodableValue, equals(Vote.Up.index));

      pt_copy = await voteOnPlaythrough(partyCode, us[1].userCode, pt.body.code.value, Vote.Up);
      expect(pt_copy.body.vote.encodableValue, equals(Vote.Up.index));
      expect(pt_copy.body.upvotes, isDefinedAndValue(equals(2)));

      pt_copy = await voteOnPlaythrough(partyCode, us[2].userCode, pt.body.code.value, Vote.Down);
      expect(pt_copy.body.vote.encodableValue, equals(Vote.Down.index));
      expect(pt_copy.body.upvotes, isDefinedAndValue(equals(2)));
      expect(pt_copy.body.downvotes, isDefinedAndValue(equals(1)));

      pt_copy = await voteOnPlaythrough(partyCode, us[0].userCode, pt.body.code.value, null);
      expect(pt_copy.body.vote.encodableValue, equals(null));
      expect(pt_copy.body.upvotes, isDefinedAndValue(equals(1)));
      expect(pt_copy.body.downvotes, isDefinedAndValue(equals(1)));
    });

    test('allows a the player to update and complete a playthrough', () async {
      final int songCode = 95945830;

      FullResponse<PartyMsg> p = await createParty();
      FullResponse<PlaythroughMsg> pt = await createPlaythrough(p.body.code.value, p.userCode, songCode);

      final PlaythroughMsg input = new PlaythroughMsg()
          ..properties.forEach((p) => p.isDefined = false)
          ..completedRatio.isDefined = true;

      Future check(double i, double o) async {
        input.completedRatio.value = i;
        FullResponse<PlaythroughMsg> pt_c = await updatePlaythrough(p.body.code.value, p.userCode, pt.body.code.value, input);
        expect(pt_c.body.completedRatio, isDefinedAndValue(equals(o)));
      }

      await check(0.0, 0.0);
      await check(0.5, 0.5);
      await check(0.25, 0.5);
      await check(null, 0.5);
      await check(1.1, 1.0);

      FullResponse<PlaythroughMsg> pt_c = await getPlaythrough(p.body.code.value, p.userCode, pt.body.code.value);
      FullResponse<Iterable<PlaythroughMsg>> pl = await getPlaylist(p.body.code.value, p.userCode);
      expect(pt_c.res.statusCode, equals(404));
      expect(pl.body, isEmpty);
    });
  });


}

