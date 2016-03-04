part of messaging;

abstract class _EnumProperty<T> extends JsonProperty<T> {
  List<T> get values;

  _EnumProperty(String name, [bool isDefined, T value]) : super(name, isDefined, value);

  int get encodableValue => (value as dynamic)?.index;

  void set encodableValue(raw) {
    if(raw is num) {
      int i = raw.toInt();
      value = (i >= 0 && i < values.length) ? values[i] : null;
    }
    else { value = null; }
  }

}

class _TransferStatusProperty extends _EnumProperty<TransferStatus> {
  final List<TransferStatus> values = TransferStatus.values;
  _TransferStatusProperty(String name, [bool isDefined, TransferStatus value]) : super(name, isDefined, value);
}

class _VoteProperty extends _EnumProperty<Vote> {
  final List<Vote> values = Vote.values;
  _VoteProperty(String name, [bool isDefined, Vote value]) : super(name, isDefined, value);
}

class _GenreProperty extends _EnumProperty<Genre> {
  final List<Genre> values = Genre.values;
  _GenreProperty(String name, [bool isDefined, Genre value]) : super(name, isDefined, value);
}



class _DurationProperty extends JsonProperty<Duration> {
  _DurationProperty(String name, [bool isDefined, Duration value]) : super(name, isDefined, value);

  int get encodableValue => value?.inMilliseconds;

  void set encodableValue(raw) {
    value = (raw is num) ? new Duration(milliseconds: raw.toInt()) : null;
  }
}

class _UriProperty extends JsonProperty<Uri> {
  _UriProperty(String name, [bool isDefined, Uri value]) : super(name, isDefined, value);

  String get encodableValue => value?.toString();

  void set encodableValue(raw) {
    value = (raw is String) ? Uri.parse(raw) : null;
  }
}