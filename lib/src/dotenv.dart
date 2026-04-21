import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

import 'errors.dart';
import 'parser.dart';

/// Loads environment variables from a `.env` file.
///
/// ## usage
///
/// Once you call (dotenv.load), the env variables can be accessed as a map
/// using the env getter of dotenv (dotenv.env).
/// You may wish to prefix the import.
///
///     import 'package:flutter_dotenv/flutter_dotenv.dart';
///
///     void main() async {
///       await dotenv.load();
///       var x = dotenv.env['foo'];
///       // ...
///     }
///
/// Verify required variables are present:
///
///     const _requiredEnvVars = const ['host', 'port'];
///     bool get hasEnv => dotenv.isEveryDefined(_requiredEnvVars);
///

DotEnv dotenv = DotEnv();

class DotEnv {
  bool _isInitialized = false;
  final Map<String, String> _envMap = {};

  /// Variables loaded at runtime from a file + any entries from mergeWith when loaded.
  Map<String, String> get env {
    if (!_isInitialized) {
      throw NotInitializedError();
    }
    return _envMap;
  }

  bool get isInitialized => _isInitialized;

  /// Clear [env] and reset initialization state
  void clean() {
    _envMap.clear();
    _isInitialized = false;
  }

  String get(String name, {String? fallback}) {
    final value = maybeGet(name, fallback: fallback);
    if (value == null) {
      throw AssertionError(
          '$name variable not found. A non-null fallback is required for missing entries');
    }
    return value;
  }

  /// Throws [AssertionError] if not found and no [fallback] given.
  /// Throws [FormatException] if found but not parseable.
  int getInt(String name, {int? fallback}) =>
      _getTyped(name, fallback, int.parse);

  /// Throws [AssertionError] if not found and no [fallback] given.
  /// Throws [FormatException] if found but not parseable.
  double getDouble(String name, {double? fallback}) =>
      _getTyped(name, fallback, double.parse);

  /// Accepts `true`/`1` and `false`/`0` (case-insensitive).
  /// Throws [AssertionError] if not found and no [fallback] given.
  /// Throws [FormatException] if found but not parseable.
  bool getBool(String name, {bool? fallback}) =>
      _getTyped(name, fallback, _parseBool);

  T _getTyped<T>(String name, T? fallback, T Function(String) parse) {
    final value = maybeGet(name);
    if (value == null && fallback == null) {
      throw AssertionError(
          '$name variable not found. A non-null fallback is required for missing entries');
    }
    return value != null ? parse(value) : fallback!;
  }

  static bool _parseBool(String value) {
    switch (value.toLowerCase()) {
      case 'true':
      case '1':
        return true;
      case 'false':
      case '0':
        return false;
      default:
        throw const FormatException('Could not parse as a bool');
    }
  }

  String? maybeGet(String name, {String? fallback}) => env[name] ?? fallback;

  /// Loads environment variables from the env file into a map
  /// Merge with any entries defined in [mergeWith]
  /// [overrideWithFiles] is a list of other env files whose values will override values read from [fileName]
  Future<void> load({
    // The name of the env file asset to load
    // This file should be defined in your pubspec.yaml assets
    String fileName = '.env',
    // A optional list of other env files whose values will override values read from [fileName]
    List<String> overrideWithFiles = const [],
    // A map of key-value pairs to merge with the loaded env variables
    Map<String, String> mergeWith = const {},
    // Whether to ignore not found and empty file errors when loading the env file(s)
    bool isOptional = false,
    // An optional custom parser to use for parsing the env file
    Parser parser = const Parser(),
  }) async {
    clean();
    List<String> linesFromFile = [];
    List<String> linesFromOverrides = [];

    try {
      linesFromFile = await _getEntriesFromFile(fileName);
    } on FileNotFoundError {
      if (!isOptional) rethrow;
    } on EmptyEnvFileError {
      if (!isOptional) rethrow;
    }

    for (final overrideFile in overrideWithFiles) {
      try {
        final lines = await _getEntriesFromFile(overrideFile);
        linesFromOverrides.addAll(lines);
      } on FileNotFoundError {
        if (!isOptional) rethrow;
      } on EmptyEnvFileError {
        if (!isOptional) rethrow;
      }
    }

    _mergeAndStore(
      linesFromFile: linesFromFile,
      linesFromOverrides: linesFromOverrides,
      mergeWith: mergeWith,
      parser: parser,
    );
  }

  void loadFromString({
    // The env string to load
    String envString = '',
    // A optional list of other env strings whose values will override values read from [envString]
    List<String> overrideWith = const [],
    // A map of key-value pairs to merge with the loaded env variables
    Map<String, String> mergeWith = const {},
    // Whether to ignore not found and empty file errors when loading the env string
    bool isOptional = false,
    // An optional custom parser to use for parsing the env string
    Parser parser = const Parser(),
  }) {
    clean();
    if (envString.isEmpty && !isOptional) {
      throw EmptyEnvFileError();
    }
    final linesFromFile = envString.split('\n');
    final linesFromOverrides = overrideWith.expand((s) => s.split('\n')).toList();

    _mergeAndStore(
      linesFromFile: linesFromFile,
      linesFromOverrides: linesFromOverrides,
      mergeWith: mergeWith,
      parser: parser,
    );
  }

  void _mergeAndStore({
    required List<String> linesFromFile,
    required List<String> linesFromOverrides,
    required Map<String, String> mergeWith,
    required Parser parser,
  }) {
    final allLines = [
      ...mergeWith.entries.map((e) => '${e.key}=${e.value}'),
      ...linesFromOverrides,
      ...linesFromFile,
    ];
    _envMap.addAll(parser.parse(allLines));
    _isInitialized = true;
  }

  /// Returns true if all supplied variables have non-empty values.
  /// Throws [NotInitializedError] if called before [load] or [loadFromString].
  bool isEveryDefined(Iterable<String> vars) =>
      vars.every((k) => env[k]?.isNotEmpty ?? false);

  Future<List<String>> _getEntriesFromFile(String filename) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final envString = await rootBundle.loadString(filename);
      if (envString.isEmpty) {
        throw EmptyEnvFileError(filename: filename);
      }
      return envString.split('\n');
    } on FlutterError {
      throw FileNotFoundError(filename);
    }
  }

}
