import 'package:test/test.dart';
import 'package:partyshark_server/identity.dart';

class ConcreteIdentifiable extends Object with Identifiable {
  //Data
  final int identity, nonIdentity;

  //Constructor
  ConcreteIdentifiable(this.identity, this.nonIdentity);
}

void main() {
  group('Identity defines', () {
    test('equality relation based on identity', () {
      final ConcreteIdentifiable
          a = new ConcreteIdentifiable(0, 0),
          b = new ConcreteIdentifiable(0, 1),
          c = new ConcreteIdentifiable(1, 0),
          d = new ConcreteIdentifiable(1, 1);

      expect(a, equals(b));
      expect(c, equals(d));

      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));

      expect(b, isNot(equals(c)));
      expect(b, isNot(equals(d)));
    });

    test('hashcodes based on identity', () {
      final ConcreteIdentifiable
        a = new ConcreteIdentifiable(0, 0),
        b = new ConcreteIdentifiable(0, 1);

      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString() representation including identity', () {
      final ConcreteIdentifiable a = new ConcreteIdentifiable(1010, 9);

      expect(a.toString(), contains('1010'));
    });
  });
}