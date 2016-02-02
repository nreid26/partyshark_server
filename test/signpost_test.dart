import 'package:test/test.dart';
import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/espionage.dart';
import 'dart:io';

const String baseUri = 'https://api.partyshark.tk';

//Stubs
class BasicRouteController extends MisrouteController {
  final List<String> supportedMethods;
  final int index;

  BasicRouteController(this.index, [this.supportedMethods = const [HttpMethod.Options]]);

  @HttpHandler(HttpMethod.Get)
  void get(HttpRequestStub req, [Map pathParams]) {
    req.routedController = this;
    req.routedMethod = HttpMethod.Get;
  }

  void handleUnroutableRequest(HttpRequestStub req, [Map pathParams]) {
    req.routedController = this;
    req.routedMethod = 'UNROUTABLE';
    super.handleUnroutableRequest(req, pathParams);
  }
}

class HttpRequestStub extends Object with Spy implements HttpRequest  {
  final String method;
  final Uri uri;
  RouteController routedController;
  String routedMethod;
  final HttpResponse response = new HttpResponseStub();

  HttpRequestStub(this.method, String uriString) : uri = Uri.parse(uriString);
}

class HttpResponseStub extends Object with Spy implements HttpResponse {
  final HttpHeaders headers = new HttpHeadersStub();
}

class HttpHeadersStub extends Object with Spy implements HttpHeaders {
  final Map<String, dynamic> _pairs = { };

  void add(String name, Object value) { _pairs[name.toLowerCase()] = value; }
  dynamic operator[](String name) => _pairs[name.toLowerCase()];
}

//Tests
void main() {
  Router router;
  List<RouteController> cons = new List.generate(4, (i) => new BasicRouteController(i));
  List<PathParameterKey> keys = new List.generate(3, (i) => new PathParameterKey());

  void build() {
    router = new Router(baseUri, cons[0], {
      'one': {
        'three': [cons[2], {
          keys[0]: cons[3]
        }],
      },
      'two': cons[1]
    });
  }

  group('${Router}s', () {
    test('support a terse definition language', () {
      expect(build, isNot(throws));
    });

    test('can route requests based on path', () {
      var cases = {'': cons[0], '/': cons[0], '/two': cons[1], '/one/three/hello': cons[3]};

      cases.forEach((String path, MisrouteController con) {
        HttpRequestStub req = new HttpRequestStub(HttpMethod.Get, '$baseUri$path');
        router.routeRequest(req);

        expect(req.routedController, equals(con));
        expect(req.routedMethod,     equals(HttpMethod.Get));
      });
    });

    test('require less than 0.05ms to route a request on average', () {
      Stopwatch watch = new Stopwatch();
      int iterations = 10000;

      watch.start();
      for(int i = 0; i < iterations; i++) {
        HttpRequestStub req = new HttpRequestStub(HttpMethod.Get, '$baseUri/one/three');
        router.routeRequest(req);
      }
      watch.stop();

      expect(watch.elapsedMilliseconds / iterations, lessThan(0.05));
    });

    test('propagate unroutable requests up the routing tree until a handler is found', () {
      var cases = {'/four': cons[0], '/one': cons[0], '/one/three/hello/goodbye': cons[3]};

      cases.forEach((String path, MisrouteController con) {
        HttpRequestStub req = new HttpRequestStub(HttpMethod.Get, '$baseUri$path');
        router.routeRequest(req);

        expect(req.routedController, equals(con));
        expect(req.routedMethod,     equals('UNROUTABLE'));
      });
    });
  });

  group('${RouteController}s', () {
    test('can recover their ${Uri}', () {
      expect(cons[0].recoverUri(),                 equals(Uri.parse(baseUri)));
      expect(cons[3].recoverUri({keys[0]: 'end'}), equals(Uri.parse('$baseUri/one/three/end')));
      expect(cons[3].recoverUri({keys[0]: 1}),     equals(Uri.parse('$baseUri/one/three/1')));
      expect(cons[3].recoverUri({keys[0]: '%'}),   equals(Uri.parse('$baseUri/one/three/%')));
    });

    test('correctly handle OPTIONS requests by default', () {
      HttpRequestStub req = new HttpRequestStub(HttpMethod.Options, 'https://api.partyshark.tk');
      router.routeRequest(req);

      expect(req.response.headers['Allow'], equals(([HttpMethod.Get, HttpMethod.Options, HttpMethod.Head]..sort()).join(',')) );
    });

    test('close responses to unsupported methods with appropriate status', () {
      HttpRequestStub req = new HttpRequestStub(HttpMethod.Connect, 'http://api.partyshark.tk');
      router.routeRequest(req);

      expect(req.response.statusCode, equals(HttpStatus.NOT_IMPLEMENTED));
    });
  });
}