part of messaging;

abstract class _EnumTransformer<T> extends TypeTransformer<T> {
  List<T> get values;

  T decode(value) {
    if(value is num) {
      int i = value.toInt();
      return (i >= 0 && i < values.length) ? values[i] : null;
    }
    return null;
  }

  int encode(T value) => value?.index;
}


class _DurationTransformer extends TypeTransformer<Duration> {
  Duration decode(value) =>
    (value is num) ? new Duration(milliseconds: value.toInt()) : null;

  int encode(Duration value) => value?.inMilliseconds;
}

class _UriTransformer extends TypeTransformer<Uri> {
  Uri decode(value) =>
    (value is String) ? Uri.parse(value) : null;

  String encode(Uri value) => value?.toString();
}

class _TransferStatusTransformer extends _EnumTransformer<TransferStatus> {
  final List<TransferStatus> values = TransferStatus.values;
}

class _VoteTransformer extends _EnumTransformer<Vote> {
  final List<Vote> values = Vote.values;
}

class _GenreTransformer extends _EnumTransformer<Genre> {
  final List<Genre> values = Genre.values;
}