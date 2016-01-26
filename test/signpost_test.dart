import 'package:test/test.dart';
import 'package:partyshark_server/signpost.dart';

class BasicRouteController extends MisrouteController {
  final List<String> supportedMethods;

  //Constructor
  BasicRouteController([this.supportedMethods = const [HttpMethod.Options]]);
}

List<PathParameterKey> keys = new List.generate(3, (i) => new PathParameterKey());

void main() {
  Router router;
  List<RouteController> cons = new List.generate(4, (i) => new BasicRouteController());

  group('${Router}s', () {
    test('support a terse definition language', () {
      void build() {
        router = new Router(cons[0], {
          'one': {
            'three': [cons[2], {
              keys[0]: cons[3]
            }],
          },
          'two': cons[1]
        });
      }

      expect(build, isNot(throws));
    });
  });

  group('${RouteController}s', () {
    test('can recover their path', () {
      expect(cons[0].getPathSegments(), orderedEquals([]));
      expect(cons[1].getPathSegments(), orderedEquals(['two']));
      expect(cons[2].getPathSegments(), orderedEquals(['one', 'three']));
      expect(cons[3].getPathSegments({keys[0]: 'end'}), orderedEquals(['one', 'three', 'end']));
      expect(cons[3].getPathSegments({keys[0]: 1}), orderedEquals(['one', 'three', '1']));
    });
  });
}