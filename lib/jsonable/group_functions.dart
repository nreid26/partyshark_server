part of jsonable;

/// Returns the result of JSON encoding the result of [toJsonGroupMap].
String toJsonGroupString(Iterable<Jsonable> msgs) => JSON.encode(toJsonGroupMap(msgs));

/// Returns the result of [fillFromJsonGroupMap] when called with the JSON
/// decoding of source.
Iterable<Jsonable> fillFromJsonGroupString(String source, Jsonable construct()) =>
  fillFromJsonGroupMap(JSON.decode(source), construct);


/// Returns a [Map] of the form:
///
///     {
///       "properties": [name_0, name_1, ...]
///       "values": [
///         [object_0.name_0, object_0.name_0, ...]
///         [...]
///       ]
///     }
///
/// where [object_n] is an indexed object in [msgs] and [name_n] is any [name]
/// in the intersection of sets of names of defined [JsonProperty] fields
/// in every [object_n].
///
/// Due to this definition, if any supplied object has an undefined property, no
/// objects will have that property specified in the return of this function.
Map<String, dynamic> toJsonGroupMap(Iterable<Jsonable> msgs) {
  if (msgs == null || msgs.isEmpty) {
    return const {
      'properties': const [ ],
      'values': const [ ]
    };
  }

  /// The intersection of the defined property names of all provided objects.
  List<String> propNames = msgs
      .map((j) => j.properties.where((p) => p.isDefined).toSet())
      .reduce((Set a, Set b) => a.intersection(b))
      .toList(growable: false);

  List<List> values = [ ];

  for(Jsonable msg in msgs) {
    List valueList = new List(propNames.length);

    for(JsonProperty prop in msg.properties) {
      int index = propNames.indexOf(prop.name);
      if(index > 0) { valueList[index] = prop.encodableValue;}
    }

    values.add(valueList);
  }

  return {
    'properties': propNames,
    'values': values
  };
}

/// This function is the inverse of [toJsonGroupMap].
///
/// Returns an [Iterable] of objects generated by calling [construct] and then
/// calling [fillFromJsonMap] on the resulting [Jsonable] with values recovered
/// from [source] as the argument. [source] should have the same structure as
/// documented for [toJsonGroupMap].
Iterable<Jsonable> fillFromJsonGroupMap(Map<String, dynamic> source, Jsonable construct()) sync* {
  List<String> propertyNames = source['properties'];

  for(List valueList in source['values']) {
    yield construct()..fillFromJsonMap(new Map.fromIterables(propertyNames, valueList));
  }
}

