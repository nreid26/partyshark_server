part of signpost_test;

/// A basic implementation fo a [MisrouteController]
class BasicRouteController extends MisrouteController {
  //Statics
  static const String Unroutable = 'UNROUTABLE';

  //Methods
  @HttpHandler(HttpMethod.Get)
  void get(HttpRequestStub req, Map pathParams) {
    req.routedController = this;
    req.routedMethod = HttpMethod.Get;
  }

  void handleUnroutableRequest(HttpRequestStub req, Map pathParams) {
    req.routedController = this;
    req.routedMethod = Unroutable;
    super.handleUnroutableRequest(req, pathParams);
  }
}
