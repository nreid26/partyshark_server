part of jsonable;

abstract class JsonProperty<T> {
  final String name;
  T value;
  bool isDefined;

  JsonProperty(this.name, [this.isDefined, this.value]) {
    isDefined = isDefined ?? true;
  }

  dynamic get encodableValue;
  void set encodableValue(dynamic raw);
}

class SimpleProperty<T> extends JsonProperty<T> {
  static const List<Type> allowedTypes = const [String, num, int, double, bool];

  SimpleProperty(String name, [bool isDefined, T value]) : super(name, isDefined, value) {
    if (T != dynamic && !allowedTypes.contains(T)) {
      throw new StateError("$T is not a valid $SimpleProperty type");
    }
  }

  dynamic get encodableValue => value;

  void set encodableValue(dynamic raw) {
    if(raw == null || raw is T) { value = raw; }
    else { throw new FormatException('$raw could not be decoded to type $T'); }
  }
}

class DateTimeProperty extends JsonProperty<DateTime> {
  DateTimeProperty(String name, [bool isDefined, DateTime value]) : super(name, isDefined, value);

  dynamic get encodableValue => value?.toIso8601String();

  void set encodableValue(dynamic raw) {
    value = (raw == null) ? null : DateTime.parse(raw);
  }

}

