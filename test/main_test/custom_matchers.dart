part of main_test;

isUndefinedOrValue(Matcher m) => new UndefinedOrValueMatcher(m);
class UndefinedOrValueMatcher extends Matcher {
  final Matcher supplied;

  UndefinedOrValueMatcher(this.supplied);

  bool matches(item, Map matchSate) {
    if (item is! JsonProperty) { return false; }
    return !item.isDefined || supplied.matches(item.value, matchSate);
  }

  Description describe(Description d) {
    d.add('a JsonProperty that is undefined or whose value matches');
    supplied.describe(d);
    return d;
  }
}

isDefinedAndValue(Matcher m) => new DefinedAndValueMatcher(m);
class DefinedAndValueMatcher extends Matcher {
  final Matcher supplied;

  DefinedAndValueMatcher(this.supplied);

  bool matches(item, Map matchSate) {
    if (item is! JsonProperty) { return false; }
    return item.isDefined && supplied.matches(item.value, matchSate);
  }

  Description describe(Description d) {
    d.add('is a JsonProperty that is defined and whose value matches');
    supplied.describe(d);
    return d;
  }
}