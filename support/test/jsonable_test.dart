import 'package:partyshark_server/jsonable/jsonable.dart';
import 'package:test/test.dart';

class ExampleMsg extends Jsonable {
  final JsonProperty<String> message = new SimpleProperty('message', false, '');
  final JsonProperty<int> count = new SimpleProperty('item_count', true, 1);
  final JsonProperty<DateTime> time = new DateTimeProperty('when');
}

void shallowMapEquals(Map a, Map b) {
  expect(a.keys, unorderedEquals(a.keys));
  a.forEach((s, k) {
    expect(a[s], equals(k));
  });
}

void main() {

  group('$JsonProperty objects', () {
    test('are defined by default', () {
      var j = new SimpleProperty('name');
      expect(j.isDefined, isTrue);
    });

    test('must be explicitly undefined', () {
      var j;

      j = new SimpleProperty('name', false);
      expect(j.isDefined, isFalse);

      j = new SimpleProperty('name', null);
      expect(j.isDefined, isTrue);

      j = new SimpleProperty('name', true);
      expect(j.isDefined, isTrue);

      j = new SimpleProperty('name')..isDefined = false;
      expect(j.isDefined, isFalse);

      j = new SimpleProperty('name')..isDefined = true;
      expect(j.isDefined, isTrue);

      j = new SimpleProperty('name')..isDefined = null;
      expect(j.isDefined, isTrue);
    });

  });

  group('$DateTimeProperty objects', () {
    test('can encode to null', () {
      var p = new DateTimeProperty(null);

      expect(p.encodableValue, isNull);
    });

    test('can encode to an ISO 8601 string', () {
      var now = new DateTime.now();
      var p = new DateTimeProperty(null)..value = now;

      expect(p.encodableValue, equals(now.toIso8601String()));
    });

    test('can decode from an ISO 8601 string', () {
      var now = new DateTime.now();
      var p = new DateTimeProperty(null)..encodableValue = now.toIso8601String();

      expect(p.value, equals(now));
    });

  });

  group('$Jsonable objects', () {
    test('have accessible properties', () {
      var msg = new ExampleMsg();

      expect(msg.properties.length, equals(3));
    });

    test('have correctly named properties', () {
      var props = new ExampleMsg().properties.map((j) => j.name);

      expect(props, unorderedEquals(['message', 'item_count', 'when']));
    });

    test('are convertable to JSON maps', () {
      var msg = new ExampleMsg()..message.isDefined = true;
      var exampleMap = msg.toJsonMap();
      var trueMap = {'message': '', 'item_count': 1, 'when': null};

      shallowMapEquals(exampleMap, trueMap);
    });

  });

  group('Group $Jsonable conversion', () {
    group('to a JSON map', () {
      test('handles null', () {
        var trueMap = {'properties': [], 'values': []};

        shallowMapEquals(toJsonGroupMap(null), trueMap);
      });

      test('handles empty iterable', () {
        var trueMap = {'properties': [], 'values': []};

        shallowMapEquals(toJsonGroupMap([]), trueMap);
      });

      test('uses intersection of defined properties', () {
        var msg1 = new ExampleMsg(), msg2 = new ExampleMsg()..message.isDefined = true;
        var exampleProps = toJsonGroupMap([msg1, msg2])['properties'];

        expect(exampleProps, unorderedEquals(['item_count', 'when']));

        msg2.count.isDefined = false;
        exampleProps = toJsonGroupMap([msg1, msg2])['properties'];

        expect(exampleProps, unorderedEquals(['when']));
      });

    });

    test('from a JSON map is invertable', null, skip: true);
  });
}