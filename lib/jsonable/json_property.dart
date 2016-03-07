part of jsonable;

/// A class representing a property in a JSON object.
///
/// When available as a field or getter in a class incorporating [Jsonable],
/// these objects will be used to generate any resulting JSON representations of
/// the owning object. [isDefined]
/// [encodableValue]
abstract class JsonProperty<T> {
  final String name;
  T value;
  bool __isDefined;

  /// Determines whether this property will be used during conversion
  /// to a JSON string; likewise it will be set to false if no
  /// property named [name] is found while reviving an owner object from source.
  ///
  /// Cannot be set to null; assigning null is equivalent to assigning true.
  bool get isDefined => __isDefined;
  void set isDefined(bool b) { __isDefined = b ?? true; }

  /// A generative constructor.
  ///
  /// If [isDefined] is not provided or null, it will default to true.
  JsonProperty(this.name, [bool isDefined, this.value]) {
    this.isDefined = isDefined;
  }

  /// Converts to and from a JSON encodable representation of [value].
  dynamic get encodableValue;
  void set encodableValue(dynamic raw);
}


/// An extension of [JsonProperty] for simple types.
///
/// This class and its direct subclasses are intended to handle directly
/// encodable JSON values.
class SimpleProperty<T> extends JsonProperty<T> {
  SimpleProperty(String name, [bool isDefined, T value]) : super(name, isDefined, value);

  /// Returns [value] identically as this is a simple JSON type.
  T get encodableValue => value;

  /// Assigns [raw] to [value] if it is the appropriate type or null.
  ///
  /// Throws a [FormatException] if an incompatible type is thrown.
  void set encodableValue(T raw) {
    if(raw == null || raw is T) { value = raw; }
    else { throw new FormatException('$raw could not be decoded to type $T'); }
  }
}


/// An extension of [JsonProperty] for [DateTime] objects.
///
/// [encodableValue] works with [String]s in ISO 8601 format.
class DateTimeProperty extends JsonProperty<DateTime> {
  DateTimeProperty(String name, [bool isDefined, DateTime value]) : super(name, isDefined, value);

  dynamic get encodableValue => value?.toIso8601String();

  void set encodableValue(dynamic raw) {
    value = (raw == null) ? null : DateTime.parse(raw);
  }

}

