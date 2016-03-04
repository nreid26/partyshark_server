part of jsonable;

String toJsonGroupString(Iterable<Jsonable> set) => JSON.encode(toJsonGroupMap(set));

Iterable<Jsonable> fillFromJsonGroupString(String source, Jsonable construct()) =>
  fillFromJsonGroupMap(JSON.decode(source), construct);


Map<String, dynamic> toJsonGroupMap(Iterable<Jsonable> set) {
  Map<String, int> indecies = set.first.toJsonMap();
  List<String> propertyNames = indecies.keys.toList(growable: false);
  List<List> values = [ ];

  int i = 0;
  for(String s in propertyNames) { indecies[s] = i; }

  for(Jsonable object in set) {
    List valueList = new List(propertyNames.length);

    for(JsonProperty prop in object.properties) {
      if(indecies.containsKey(prop.name)) {
        valueList[indecies[prop.name]] = prop.encodableValue;
      }
    }

    values.add(valueList);
  }

  return {
    'properties': propertyNames,
    'values': values
  };
}

Iterable<Jsonable> fillFromJsonGroupMap(Map<String, dynamic> source, Jsonable construct()) sync* {
  List<String> propertyNames = source['properties'];

  for(List valueList in source['values']) {
    yield construct()..fillFromJsonMap(new Map.fromIterables(propertyNames, valueList));
  }
}

