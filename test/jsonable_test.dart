import 'package:partyshark_server/jsonable/jsonable.dart';

class ExampleMsg extends Jsonable {
  final JsonProperty<String> message = new SimpleProperty('message');
}

void main() {
  var exmaple = new ExampleMsg()..message.value = 'hello';

  print(exmaple.toJsonString());
}