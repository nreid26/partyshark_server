import 'package:partyshark_server/src/randomization_service/randomization_service.dart' as rand_serve;
import 'package:test/test.dart';

main() async {

  await rand_serve.ready;

  group('randomization_service', () {
    test('generates satisfactory usernames', () {
      final RegExp exp = new RegExp(r'^[a-z]{3,}_[a-z]{3,}$');

      for(int i = 0; i < 10; i++) {
        expect(rand_serve.username, matches(exp));
      }
    });

  });
}