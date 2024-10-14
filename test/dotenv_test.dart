import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dotenv', () {
    setUp(() {
      print(Directory.current.toString());
      dotenv.testLoad(
          fileInput: File('test/.env')
              .readAsStringSync()); // mergeWith: Platform.environment
    });
    test('when .env is loaded we should be able to get the .env variables', () {
      expect(dotenv.env['FOO'], 'foo');
      expect(dotenv.env['BAR'], 'bar');
      expect(dotenv.env['FOOBAR'], '\$FOOfoobar');
      expect(dotenv.env['ESCAPED_DOLLAR_SIGN'], '\$1000');
      expect(dotenv.env['ESCAPED_QUOTE'], "'");
      expect(dotenv.env['BOOL_TRUE'], "true");
      expect(dotenv.env['BOOL_1'], "1");
      expect(dotenv.env['BOOL_FALSE'], "false");
      expect(dotenv.env['BOOL_0'], "0");
      expect(dotenv.env['INT_42'], "42");
      expect(dotenv.env['INT_42_NEGATIVE'], "-42");
      expect(dotenv.env['DOUBLE_13_37'], "13.37");
      expect(dotenv.env['DOUBLE_13_37_NEGATIVE'], "-13.37");
      expect(dotenv.env['DOUBLE_1e3'], "1.e3");
      expect(dotenv.env['DOUBLE_POINT_3'], ".3");
      expect(dotenv.env['BASIC'], 'basic');
      expect(dotenv.env['AFTER_LINE'], 'after_line');
      expect(dotenv.env['EMPTY'], '');
      expect(dotenv.env['SINGLE_QUOTES'], 'single_quotes');
      expect(dotenv.env['SINGLE_QUOTES_SPACED'], '    single quotes    ');
      expect(dotenv.env['DOUBLE_QUOTES'], 'double_quotes');
      expect(dotenv.env['DOUBLE_QUOTES_SPACED'], '    double quotes    ');
      expect(dotenv.env['EXPAND_NEWLINES'], "expand\nnew\nlines");
      expect(dotenv.env['DONT_EXPAND_UNQUOTED'], 'dontexpand\\nnewlines');
      expect(dotenv.env['DONT_EXPAND_SQUOTED'], 'dontexpand\\nnewlines');
      expect(dotenv.env['COMMENTS'], null);
      expect(dotenv.env['EQUAL_SIGNS'], 'equals==');
      expect(dotenv.env['RETAIN_INNER_QUOTES'], '{"foo": "bar"}');
      expect(dotenv.env['RETAIN_LEADING_DQUOTE'], "\"retained");
      expect(dotenv.env['RETAIN_LEADING_SQUOTE'], '\'retained');
      expect(dotenv.env['RETAIN_TRAILING_DQUOTE'], 'retained\"');
      expect(dotenv.env['RETAIN_TRAILING_SQUOTE'], "retained\'");
      expect(dotenv.env['RETAIN_INNER_QUOTES_AS_STRING'], '{"foo": "bar"}');
      expect(dotenv.env['TRIM_SPACE_FROM_UNQUOTED'], 'some spaced out string');
      expect(dotenv.env['USERNAME'], 'therealnerdybeast@example.tld');
      expect(dotenv.env['SPACED_KEY'], 'parsed');
    });
    test(
        'when getting a vairable that is not in .env, we should get the fallback we defined',
        () {
      expect(dotenv.get('FOO', fallback: 'bar'), 'foo');
      expect(dotenv.get('COMMENTS', fallback: 'sample'), 'sample');
      expect(dotenv.get('EQUAL_SIGNS', fallback: 'sample'), 'equals==');
    });
    test(
        'when getting a vairable that is not in .env, we should get an error thrown',
        () {
      expect(() => dotenv.get('COMMENTS'), throwsAssertionError);
    });
    test(
        'when getting a vairable using the nullable getter, we should get null if no fallback is defined',
        () {
      expect(dotenv.maybeGet('COMMENTS'), null);
      expect(dotenv.maybeGet('COMMENTS', fallback: 'sample'), 'sample');
      expect(dotenv.maybeGet('EQUAL_SIGNS', fallback: 'sample'), 'equals==');
    });
    test('int getting works', () {
      expect(dotenv.getInt('INT_42'), 42);
      expect(dotenv.getInt('INT_42_NEGATIVE'), -42);
      expect(() => dotenv.getInt('COMMENTS'), throwsAssertionError);
      expect(dotenv.getInt('COMMENTS', fallback: 42), 42);
      expect(() => dotenv.getInt('FOO'), throwsFormatException);
    });
    test('double getting works', () {
      expect(dotenv.getDouble('DOUBLE_13_37'), 13.37);
      expect(dotenv.getDouble('DOUBLE_13_37_NEGATIVE'), -13.37);
      expect(dotenv.getDouble('DOUBLE_1e3'), 1e3);
      expect(dotenv.getDouble('DOUBLE_POINT_3'), .3);
      expect(() => dotenv.getDouble('COMMENTS'), throwsAssertionError);
      expect(dotenv.getDouble('COMMENTS', fallback: .3), .3);
      expect(() => dotenv.getDouble('FOO'), throwsFormatException);
    });
    test('bool getting works', () {
      expect(dotenv.getBool('BOOL_TRUE'), true);
      expect(dotenv.getBool('BOOL_1'), true);
      expect(dotenv.getBool('BOOL_FALSE'), false);
      expect(dotenv.getBool('BOOL_0'), false);
      expect(() => dotenv.getBool('COMMENTS'), throwsAssertionError);
      expect(dotenv.getBool('COMMENTS', fallback: true), true);
      expect(dotenv.getBool('COMMENTS', fallback: false), false);
      expect(() => dotenv.getBool('FOO'), throwsFormatException);
    });
  });
}
