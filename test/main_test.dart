import 'package:test/test.dart';
import 'dart:convert';
import 'dart:io';

main() async {
  final Uri baseUri = Uri.parse('http://localhost:3000');
  final HttpClient client = new HttpClient();
  final Process server = await Process.start('dart ../bin/main.dart', ['$baseUri', '3000', '-l', '0', '-T'])
    ..stderr.transform(UTF8.decoder).transform(new LineSplitter()).listen(print);

}