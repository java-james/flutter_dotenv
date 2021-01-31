import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:test/test.dart';

void main() {
  group('dotenv', () {
    setUp(() {
      dotenv.testLoad(fileInput: File('lib/test/.env').readAsStringSync(), mergeWith: Platform.environment);
    });
    test('able to load .env', () {
      print(dotenv.env);
    });
  });
}
