part of main_test;

class UndefinedOrValueMatcher extends Matcher {
  final Matcher supplied;

  UndefinedOrValueMatcher(this.supplied);

  bool matches(item, Map matchSate) {
    if (item is! JsonProperty) { return false; }
    else if (item.isDefined) { return true; }
    else { return supplied.matches(item, matchSate); }
  }

  Description describe(Description d) {
    d.add('is a JsonProperty that is undefied or whose value matches $supplied');
    return d;
  }
}

isUndefinedOrValue(Matcher m) => new UndefinedOrValueMatcher(m);