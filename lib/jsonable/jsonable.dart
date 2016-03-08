/// A library for working with strongly typed JSON objects.
///
/// Ideally, classes from this library will be used as the bas for custom
/// message objects, not long term entities. Reflection is used but no symbols
/// need be maintained for it to work.
library jsonable;

@MirrorsUsed()
import 'dart:mirrors';
import 'dart:convert' show JSON;

part './json_property.dart';
part './group_functions.dart';

/// A mixin of base class providing the functionality of JSON encoding the
/// [JsonProperty] members of the incorporating class.
abstract class Jsonable {

  /// Returns an [Iterable] of the [JsonProperty] fields of this object
  /// as declared in its most derived subclass.
  Iterable<JsonProperty> get properties sync* {
    var im = reflect(this), cm = im.type;
    var instanceFields = cm.declarations.values.where((dm) => dm is VariableMirror && !dm.isStatic);

    for (VariableMirror vm in instanceFields) {
      var p = im.getField(vm.simpleName).reflectee;
      if(p is JsonProperty) { yield p; }
    }
  }

  /// Revives this object with the JSON data in [source].
  ///
  /// Equivalent to calling [fillFromJsonMap] with the result of calling
  /// JSON decode on [source].
  void fillFromJsonString(String source) {
    fillFromJsonMap(JSON.decode(source));
  }

  /// Returns the JSON string representation of this object's [JsonProperty]
  /// fields as given by [properties].
  String toJsonString() => JSON.encode(toJsonMap());

  /// Equivalent to [toJsonString].
  String toString() => toJsonString();

  /// Returns a JSON encodable [Map] of the [JsonProperty] fields of this
  /// object as given by [properties].
  ///
  /// The keys and values will be the [name] and [encodableValue] properties
  /// of each [JsonProperty].
  Map<String, dynamic> toJsonMap() {
    Map ret = { };
    for(JsonProperty p in properties) {
      if (p.isDefined) { ret[p.name] = p.encodableValue; }
    }
    return ret;
  }

  /// Revives this object with the JSON data in [source].
  ///
  /// [JsonProperty] fields of this object as given by [properties] will have
  /// their [encodableValue] assigned the value of the element of [source]
  /// whose key equals their [name]. If no such element exists, that property
  /// will have [isDefined] set to false.
  void fillFromJsonMap(Map<String, dynamic> source) {
    for(JsonProperty p in properties) {
      p
          ..encodableValue = source[p.name]
          ..isDefined = source.containsKey(p.name);
    }
  }
}