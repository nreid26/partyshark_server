part of signpost_test;

/// A class implementing the features of [HttpRequest] depended on by signpost
class HttpRequestStub extends Spy implements HttpRequest  {
  final String method;
  final Uri uri;
  RouteController routedController;
  String routedMethod;
  final HttpResponse response = new HttpResponseStub();

  HttpRequestStub(this.method, String uriString) : uri = Uri.parse(uriString);
}

/// A class implementing the features of [HttpResponse] depended on by signpost
class HttpResponseStub extends Spy implements HttpResponse {
  final HttpHeaders headers = new HttpHeadersStub();
}

/// A class implementing the features of [HttpHeaders] depended on by signpost
class HttpHeadersStub extends Spy implements HttpHeaders {
  final Map<String, dynamic> _pairs = { };

  dynamic operator[](String name) => _pairs[name.toLowerCase()];

  void set(String name, Object value) { _pairs[name.toLowerCase()] = value; }

  void add(String name, Object value) {
    if(_pairs.containsKey(name)) { _pairs[name] += ',$value'; }
    else { _pairs[name] = value.toString(); }
  }
}
