import 'package:test/test.dart';
import 'package:partyshark_server/identity.dart';
import 'package:partyshark_server/pseudobase.dart';

class ConcreteIdentifiable extends Identifiable {
	//Data
	final int nonIdentity;

	//Constructor
	ConcreteIdentifiable(this.nonIdentity, [int id]) {
		if(id != null) { identity = id; }
	}
}

void main() {
	group('Datastores', () {
		test('must have types which subclass Identifiable', () {
			expect(() => new Datastore([String, int, Error]), throws);
			expect(() => new Datastore([ConcreteIdentifiable]), isNot(throws));
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

		test('can have items added and be cleared', () {
			expect(table.length, equals(0));

			ConcreteIdentifiable c = new ConcreteIdentifiable(0, 84);
			table.add(c);
			expect(table.length, equals(1));
			expect(table.containsIdentity(84), equals(true));
			expect(table[84], equals(c));

			table.clear();
			expect(table.length, equals(0));
			expect(table.containsIdentity(84), equals(false));
			expect(table[84], equals(null));
		});

		test('can handle at least 10000 items', () {
			for(int i = 0; i < 1000; i++) {
				var x = new ConcreteIdentifiable(i, i);
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

		test('set a unique identity on unidentified items', () {
			ConcreteIdentifiable c = new ConcreteIdentifiable(0);
			table.add(c);

			expect(c.hasIdentity,                      equals(true));
			expect(table[c.identity],                  equals(c));
			expect(table.containsIdentity(c.identity), equals(true));
		});

		test('can have their items removed by identity', () {
			int l = table.length;

			for(int i = 0; i < 500; i++) {
				expect(table.removeIdentity(i), equals(true));
				expect(table[i],                equals(null));
				expect(table.length,            equals(--l));
			}
		});

		test('can have their items removed by value', () {
			int l = table.length;

			for(int i = 500; i < 1000; i++) {
				expect(table.remove(table[i]), equals(true));
				expect(table[i],               equals(null));
				expect(table.length,           equals(--l));
			}
		});
	});

	group('${Datastore}s', () {
		var store = new Datastore([ConcreteIdentifiable]), table = store[ConcreteIdentifiable];

		test('can add to ${Table}s directly by $Type}', () {
			ConcreteIdentifiable c = new ConcreteIdentifiable(9);

      expect(store.add(c), equals(true));
			expect(table.length,      equals(1));
			expect(table.contains(c), equals(true));

      table.clear();
		});

		test('can remove from ${Table}s directly by $Type', () {
      int l = table.length;
			ConcreteIdentifiable c = new ConcreteIdentifiable(0, 95);
			table.add(c);

			expect(store.remove(c), equals(true));
			expect(table.length, equals(l));
			expect(table.containsIdentity(95), equals(false));
		});

	});
}