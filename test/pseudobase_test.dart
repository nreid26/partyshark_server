import 'package:test/test.dart';
import 'package:partyshark_server/identity.dart';
import 'package:partyshark_server/pseudobase.dart';

class ConcreteIdentifiable implements Identifiable {
	//Data
	final int identity;

	//Constructor
	ConcreteIdentifiable(this.identity);
}

void main() {
	group('Datastores', () {
		test('must have types which subclass Identifiable', () {
			expect(() => new Datastore([String, int, Error]), throwsArgumentError);
			expect(() => new Datastore([ConcreteIdentifiable]),
					isNot(throwsArgumentError));
		});

		test('determines if table exists', () {
			var store = new Datastore([ConcreteIdentifiable]);

      expect(store.hasTable(ConcreteIdentifiable), equals(true));
      expect(store.hasTable(String), equals(false));
		});

		test('can locate tables based on type', () {
			var store = new Datastore([ConcreteIdentifiable]);

      expect(store[ConcreteIdentifiable], equals(store[ConcreteIdentifiable]));
		});
	});
}