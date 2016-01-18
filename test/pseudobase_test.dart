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
			expect(() => new Datastore([String, int, Error]), throws);
			expect(() => new Datastore([ConcreteIdentifiable]), isNot(throws));
		});

		test('must have only one Table per Type', () {
			expect(() => new Datastore([ConcreteIdentifiable, ConcreteIdentifiable]), throws);
		});

		var store = new Datastore([ConcreteIdentifiable]);

		test('can determines if a Table exists', () {
      expect(store.hasTable(ConcreteIdentifiable), equals(true));
      expect(store.hasTable(String), equals(false));
		});

		test('can locate Tables based on Type and not by invalid Type', () {
      expect(() => store[ConcreteIdentifiable], isNot(throws));
			expect(() => store[int], throws);
		});

		test('have consistent Table references', () {
			expect(store[ConcreteIdentifiable], equals(store[ConcreteIdentifiable]));
		});
	});

	group('Tables', () {
		var store = new Datastore([ConcreteIdentifiable]), table = store[ConcreteIdentifiable], refList = [];

		test('have references to their Datastore', () {
			expect(table.datastore, equals(store));
		});

		test('can have at least 1000 items added', () {
			for(int i = 0; i < 1000; i++) {
				var x = new ConcreteIdentifiable(i);
				expect(table.add(x), equals(true));
				expect(table.length, equals(i + 1));
				refList.add(x);
			}
		});

		test('can have items queried by identity', () {
			for(int i = 0; i < 1000; i++) {
				expect(table[i], equals(refList[i]));
			}
		});

		test('have valid Iterators', () {
			var refListCopy = new List.from(refList);

			for(ConcreteIdentifiable c in table) {
				expect(refListCopy.remove(c), equals(true));
			}
			expect(refListCopy.length, equals(0));
		});

		test('can have their items removed by identity', () {
			for(int i = 0; i < 500; i++) {
				expect(table.removeIdentity(i), equals(true));
				expect(table[i], equals(null));
				expect(table.length, equals(1000 - 1 - i));
			}
		});

		test('can have their items removed by value', () {
			for(int i = 500; i < 1000; i++) {
				expect(table.remove(table[i]), equals(true));
				expect(table[i], equals(null));
				expect(table.length, equals(1000 - 1 - i));
			}
		});

		test('update their nextIdentity to ensure it is unique', () {
			for(int i = 10; i < 15; i++) {
				expect(table.where((ConcreteIdentifiable c) => c.identity == table.nextIdentity).length, equals(0));
				table.add(new ConcreteIdentifiable(table.nextIdentity));
			}
		});
	});
}