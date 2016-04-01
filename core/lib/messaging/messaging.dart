/// A library defining [Jsonable] message objects and helper classes and functions
/// to assist other core libraries in working with API data in JSON format.
library messaging;

import 'package:partyshark_server_support/jsonable/jsonable.dart';
import 'package:partyshark_server_core/model/model.dart';

export 'package:partyshark_server_support/jsonable/jsonable.dart';

part './messages.dart';
part './custom_properties.dart';
part './mixins.dart';
