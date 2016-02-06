library signpost_test;

import 'dart:io';

import 'package:test/test.dart';
import 'package:partyshark_server/signpost/signpost.dart';
import 'package:partyshark_server/espionage.dart';

part './http_stubs.dart';
part './basic_route_controller.dart';


const String baseUri = 'https://api.partyshark.tk';

final RouteController 
  C0 = new BasicRouteController(),
  C1 = new BasicRouteController(),
  C2 = new BasicRouteController(),
  C3 = new BasicRouteController();

final PathParameterKey 
  K0 = new PathParameterKey(),
  K1 = new PathParameterKey(),
  K2 = new PathParameterKey();

final routerDefinition = {
    'one': {
      'three': [C2, {
        K0: C3 }], },
    'two': C1 };

Router router;


void main() {
  group('${Router}s', () {
    test('support a terse definition language', () {
      expect(() => new Router(baseUri, C0, routerDefinition), returnsNormally);
      router = new Router(baseUri, C0, routerDefinition);
    });

    test('can route requests based on path', () {
      final cases = {'': C0, '/': C0, '/two': C1, '/one/three/hello': C3};

      cases.forEach((String path, MisrouteController con) async {
        HttpRequestStub req = new HttpRequestStub(HttpMethod.Get, '$baseUri$path');
        await router.routeRequest(req);

        expect(req.routedController, equals(con));
        expect(req.routedMethod,     equals(HttpMethod.Get));
      });
    });

    test('can route at least 10000 requests per second', () {
      Stopwatch watch = new Stopwatch();

      watch.start();
      for(int i = 0; i < 10000; i++) {
        HttpRequestStub req = new HttpRequestStub(HttpMethod.Get, '$baseUri/one/three');
        router.routeRequest(req);
      }
      watch.stop();

      expect(watch.elapsedMilliseconds, lessThan(1000));
    });

    test('propagate unroutable requests up the routing tree until a handler is found', () {
      final cases = {'/four': C0, '/one': C0, '/one/three/hello/goodbye': C3};

      cases.forEach((String path, MisrouteController con) async {
        HttpRequestStub req = new HttpRequestStub(HttpMethod.Get, '$baseUri$path');
        await router.routeRequest(req);

        expect(req.routedController, equals(con));
        expect(req.routedMethod,     equals(BasicRouteController.Unroutable));
      });
    });
  });

  group('${RouteController}s', () {
    test('can recover their ${Uri}', () {
      final cases = [
        [C0, null, ''],
        [C3, {K0: 'end'}, '/one/three/end'],
        [C3, {K0: 1}, '/one/three/1'],
        [C3, {K0: '%'}, '/one/three/%']
      ];

      for(List c in cases) {
        expect(c[0].recoverUri(c[1]), equals(Uri.parse(baseUri + c[2])));
      }
    });

    test('correctly handle OPTIONS requests by default', () async {
      final methodNames = [HttpMethod.Get, HttpMethod.Options, HttpMethod.Head];
      HttpRequestStub req = new HttpRequestStub(HttpMethod.Options, baseUri);

      await router.routeRequest(req);

      expect(req.response.headers['Allow'], equals((methodNames..sort()).join(',')));
    });

    test('close responses to unsupported methods with appropriate status', () async {
      HttpRequestStub req = new HttpRequestStub(HttpMethod.Connect, baseUri);
      await router.routeRequest(req);

      expect(req.response.statusCode, equals(HttpStatus.METHOD_NOT_ALLOWED));
    });
  });
}