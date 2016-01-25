import 'package:test/test.dart';
import 'package:partyshark_server/signpost.dart';

class BasicRouteController extends MisrouteController {
  final List<String> supportedMethods;

  //Constructor
  BasicRouteController(this.supportedMethods);
}

void main() {
  group('${RouteController}s', () {
    test('require \'supportedMethods\' getter', () {
      expect(() => new BasicRouteController(null), throwsStateError);
      expect(() => new BasicRouteController(const [HttpMethod.Options]), isNot(throwsStateError));
    });


  });
}