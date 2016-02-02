part of server_lib;

///A class implementing random value generation functions needed by the server
class _RandService {
  ///A sorted string containing all the lowercase characters.
  static const String lowercaseAlphabet = 'abcdefghijklmnopqrstuvwxyz';

  ///The internal random number generator at the core of the provided services.
  static final Random __rand = new Random();


  ///An internal function used to assemble file data for the [username] service.
  static Map<String, Set<String>> __setMapFromFile(String filename) {
    Map map = { };
    for (String s in new File(filename).readAsLinesSync()) {
      if (!map.containsKey(s[0])) {
        map[s[0]] = new Set<String>();
      }
      map[s[0]].add(s);
    }
    return map;
  }


  ///An internal function returning a random non-negative integer with the
  /// specified number of bits
  static int __randIntBits(int bits) => __rand.nextInt(1 << bits);


  ///Returns an entry at random from the provided structure. May be a [String],
  /// [Map], or [Iterable]. If a seed is provided the result is fully
  /// deterministic.
  static dynamic draw(dynamic struct, [int seed]) {
    seed = (seed == null) ? __rand.nextInt(struct.length - 1) : seed % struct.length;

    if(struct is String) { return struct[seed]; }
    if(struct is Map) { return struct.values.elementAt(seed); }
    else { return struct.elementAt(seed); }
  }


  ///File data for use in [username] service.
  static final Map<String, Set<String>>
      __animals = __setMapFromFile('./resc/animals.txt'),
      __adjectives = __setMapFromFile('./resc/adjectives.txt');

  ///Service for retrieving a random username.
  static String get username {
    int seed = __rand.nextInt(1 << 32);

    String letter = draw(lowercaseAlphabet, seed);
    return '${draw(__adjectives[letter], seed)}_${draw(__animals[letter], seed)}';
  }


  ///Service for retrieving a random administrator code.
  static int get adminCode => __randIntBits(24);


  ///Service for retrieving a random user code.
  static int get usercode => __randIntBits(64);


  ///A private stub constructor to prevent subclassing.
  _RandService.__internal();

}