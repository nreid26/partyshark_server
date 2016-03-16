import 'package:args/args.dart';

class ArgManager {
  static const String __Logging = 'logging';

  static final ArgParser __parser = new ArgParser()
    ..addOption(__Logging, abbr: 'l');


  final List<String> __args;
  final ArgResults __argMap;

  ArgManager(List<String> args) :
      __args = args,
      __argMap = __parser.parse(args.skip(2).toList(growable: false));


  String get baseUri => __args[0];
  int get port => int.parse(__args[1]);
  int get logLevel => __argMap.wasParsed(__Logging) ? int.parse(__argMap[__Logging]) : 4;
}



