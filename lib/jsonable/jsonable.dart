library jsonable;

@MirrorsUsed()
import 'dart:mirrors';
import 'dart:convert' show JSON;

part './json_property.dart';
part './group_functions.dart';


abstract class Jsonable {
  Iterable<JsonProperty> get properties sync* {
    var im = reflect(this), cm = im.type;

    for (DeclarationMirror dm in cm.declarations.values) {
      if (dm is VariableMirror  || dm is MethodMirror && dm.isGetter) {
        var p = im.getField(dm.simpleName).reflectee;
        if(p is JsonProperty) { yield p; }
      }
    }
  }


  void fillFromJsonString(String source) {
    fillFromJsonMap(JSON.decode(source));
  }

  String toJsonString() => JSON.encode(toJsonMap());

  String toString() => toJsonString();


  Map<String, dynamic> toJsonMap() {
    Map ret = { };
    for(JsonProperty p in properties) {
      if (p.isDefined) { ret[p.name] = p.encodableValue; }
    }
    return ret;
  }

  void fillFromJsonMap(Map<String, dynamic> source) {
    for(JsonProperty p in properties) {
      p
          ..encodableValue = source[p.name]
          ..isDefined = source.containsKey(p.name);
    }
  }
}