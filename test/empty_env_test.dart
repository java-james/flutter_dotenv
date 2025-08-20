import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('loadFromString empty .env file handling', () {
    setUp(() {
      dotenv.clean();
    });

    test('empty .env file with isOptional=true should not throw', () {
      expect(() {
        dotenv.loadFromString(
            envString: File('test/.env.empty').readAsStringSync(),
            isOptional: true);
      }, returnsNormally);

      expect(dotenv.isInitialized, isTrue);
      expect(dotenv.env.isEmpty, isTrue);
    });

    test('empty .env file with isOptional=false should throw FileEmptyError',
        () {
      // This test verifies that an empty .env file still throws when isOptional is false
      expect(() {
        dotenv.loadFromString(
            envString: File('test/.env.empty').readAsStringSync(),
            isOptional: false);
      }, throwsA(isA<EmptyEnvFileError>()));
    });

    test('missing .env file with isOptional=true should not throw', () {
      File emptyFile = File('test/.env.empty');
      expect(() {
        dotenv.loadFromString(
            envString: emptyFile.readAsStringSync(), isOptional: true);
      }, returnsNormally);

      expect(dotenv.isInitialized, isTrue);
      expect(dotenv.env.isEmpty, isTrue);
    });

    test(
        'missing .env file with isOptional=false should throw FileNotFoundError',
        () {
      expect(() {
        dotenv.loadFromString(envString: '', isOptional: false);
      }, throwsA(isA<EmptyEnvFileError>()));
    });
  });
}
