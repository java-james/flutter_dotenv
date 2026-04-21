import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotInitializedError', () {
    test('toString contains actionable guidance', () {
      final error = NotInitializedError();
      expect(error.toString(), contains('NotInitializedError'));
      expect(error.toString(), contains('load()'));
      expect(error.toString(), contains('loadFromString()'));
    });

    test('is thrown when accessing env before initialization', () {
      final env = DotEnv();
      expect(() => env.env, throwsA(isA<NotInitializedError>()));
    });

    test('thrown error message does not reference global singleton', () {
      final env = DotEnv();
      try {
        env.env;
        fail('should have thrown');
      } on NotInitializedError catch (e) {
        expect(e.toString(), contains('load()'));
        expect(e.toString(), isNot(contains('dotenv.load')));
      }
    });
  });

  group('FileNotFoundError', () {
    test('toString contains the filename when provided', () {
      final error = FileNotFoundError('.env');
      expect(error.toString(), contains('FileNotFoundError'));
      expect(error.toString(), contains('.env'));
      expect(error.toString(), contains('pubspec.yaml'));
    });

    test('toString provides generic message when no filename given', () {
      final error = FileNotFoundError();
      expect(error.toString(), contains('FileNotFoundError'));
      expect(error.toString(), contains('not found'));
    });

    test('filename field is accessible', () {
      expect(FileNotFoundError('.env.production').filename, '.env.production');
      expect(FileNotFoundError().filename, isNull);
    });
  });

  group('EmptyEnvFileError from loadFromString', () {
    test('thrown error message describes empty string context', () {
      final env = DotEnv();
      try {
        env.loadFromString(envString: '');
        fail('should have thrown');
      } on EmptyEnvFileError catch (e) {
        expect(e.toString(), contains('empty'));
        expect(e.filename, isNull);
      }
    });
  });

  group('EmptyEnvFileError', () {
    test('toString contains the filename when provided', () {
      final error = EmptyEnvFileError(filename: '.env');
      expect(error.toString(), contains('EmptyEnvFileError'));
      expect(error.toString(), contains('.env'));
      expect(error.toString(), contains('empty'));
    });

    test('toString provides generic message when no filename given', () {
      final error = EmptyEnvFileError();
      expect(error.toString(), contains('EmptyEnvFileError'));
      expect(error.toString(), contains('empty'));
    });

    test('filename field is accessible', () {
      expect(EmptyEnvFileError(filename: '.env').filename, '.env');
      expect(EmptyEnvFileError().filename, isNull);
    });
  });
}
