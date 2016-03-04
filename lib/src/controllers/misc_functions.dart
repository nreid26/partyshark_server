part of controllers;

/// A convenience function for converting an [int] to a Base64 [String] with
/// preserved endianness.
String encodeBase64(int value, [int bytes = -1]) {
  bytes = bytes.isNegative ? (value.bitLength ~/ 8 + 1) : bytes;
  Uint8ClampedList l = new Uint8ClampedList(bytes);

  for(int i = l.length - 1; i >= 0; i--) {
    l[i] = value;
    value >>= 8;
  }

  return BASE64.encode(l);
}

/// A convenience function for converting a Base64 [String] to an [int] with
/// preserved endianness.
int decodeBase64(String value) {
  if(value == null) { return null; }

  List<int> l;
  int ret = 0;

  try { l = BASE64.decode(value); }
  catch (e) { return null; }

  for(int i = 0; i < l.length; i++) {
    ret <<= 8;
    ret |= l[i];
  }

  return ret;
}

