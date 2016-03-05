import 'package:partyshark_server/deezer.dart' as deezer;

main() async {
  print(await deezer.getSong(9040923));
}