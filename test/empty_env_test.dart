import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Empty .env file handling', () {
    setUp(() {
      dotenv.clean();
    });

    test('empty .env file with isOptional=true should not throw', () async {
      // This test verifies that an empty .env file behaves the same as a missing file
      // when isOptional is set to true.
      expect(() async {
        await dotenv.load(fileName: 'test/.env.empty', isOptional: true);
      }, returnsNormally);
      
      expect(dotenv.isInitialized, isTrue);
      expect(dotenv.env.isEmpty, isTrue);
    });

    test('empty .env file with isOptional=false should throw EmptyEnvFileError', () async {
      // This test verifies that an empty .env file still throws when isOptional is false
      expect(() async {
        await dotenv.load(fileName: 'test/.env.empty', isOptional: false);
      }, throwsA(isA<EmptyEnvFileError>()));
    });

    test('missing .env file with isOptional=true should not throw', () async {
      // This test verifies the existing behavior for missing files works correctly
      expect(() async {
        await dotenv.load(fileName: 'test/.env.missing', isOptional: true);
      }, returnsNormally);
      
      expect(dotenv.isInitialized, isTrue);
      expect(dotenv.env.isEmpty, isTrue);
    });

    test('missing .env file with isOptional=false should throw FileNotFoundError', () async {
      // This test verifies the existing behavior for missing files works correctly
      expect(() async {
        await dotenv.load(fileName: 'test/.env.missing', isOptional: false);
      }, throwsA(isA<FileNotFoundError>()));
    });
  });
}