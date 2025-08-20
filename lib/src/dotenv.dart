import 'dart:async';

import 'package:flutter/material.dart';
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

  /// A copy of variables loaded at runtime from a file + any entries from mergeWith when loaded.
  Map<String, String> get env {
    if (!_isInitialized) {
      throw NotInitializedError();
    }
    return _envMap;
  }

  bool get isInitialized => _isInitialized;

  /// Clear [env]
  void clean() => _envMap.clear();

  String get(String name, {String? fallback}) {
    final value = maybeGet(name, fallback: fallback);
    if (value == null) {
      throw AssertionError(
          '$name variable not found. A non-null fallback is required for missing entries');
    }
    return value;
  }

  /// Load the enviroment variable value as an [int]
  ///
  /// If variable with [name] does not exist then [fallback] will be used.
  /// However if also no [fallback] is supplied an error will occur.
  ///
  /// Furthermore an [FormatException] will be thrown if the variable with [name]
  /// exists but can not be parsed as an [int].
  int getInt(String name, {int? fallback}) {
    final value = maybeGet(name);
    assert(value != null || fallback != null,
        'A non-null fallback is required for missing entries');
    return value != null ? int.parse(value) : fallback!;
  }

  /// Load the enviroment variable value as a [double]
  ///
  /// If variable with [name] does not exist then [fallback] will be used.
  /// However if also no [fallback] is supplied an error will occur.
  ///
  /// Furthermore an [FormatException] will be thrown if the variable with [name]
  /// exists but can not be parsed as a [double].
  double getDouble(String name, {double? fallback}) {
    final value = maybeGet(name);
    assert(value != null || fallback != null,
        'A non-null fallback is required for missing entries');
    return value != null ? double.parse(value) : fallback!;
  }

  /// Load the enviroment variable value as a [bool]
  ///
  /// If variable with [name] does not exist then [fallback] will be used.
  /// However if also no [fallback] is supplied an error will occur.
  ///
  /// Furthermore an [FormatException] will be thrown if the variable with [name]
  /// exists but can not be parsed as a [bool].
  bool getBool(String name, {bool? fallback}) {
    final value = maybeGet(name);
    assert(value != null || fallback != null,
        'A non-null fallback is required for missing entries');
    if (value != null) {
      if (['true', '1'].contains(value.toLowerCase())) {
        return true;
      } else if (['false', '0'].contains(value.toLowerCase())) {
        return false;
      } else {
        throw const FormatException('Could not parse as a bool');
      }
    }

    return fallback!;
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
    List<String> linesFromFile;
    List<String> linesFromOverrides;
    try {
      linesFromFile = await _getEntriesFromFile(fileName);
      linesFromOverrides = await _getLinesFromOverride(overrideWithFiles);
    } on FileNotFoundError {
      if (!isOptional) rethrow;
      linesFromFile = [];
      linesFromOverrides = [];
    } on EmptyEnvFileError {
      if (!isOptional) rethrow;
      linesFromFile = [];
      linesFromOverrides = [];
    }

    final linesFromMergeWith = mergeWith.entries
        .map((entry) => "${entry.key}=${entry.value}")
        .toList();
    final allLines = linesFromMergeWith
      ..addAll(linesFromOverrides)
      ..addAll(linesFromFile);
    final envEntries = parser.parse(allLines);
    _envMap.addAll(envEntries);
    _isInitialized = true;
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
    final linesFromOverrides = overrideWith
        .map((String lines) => lines.split('\n'))
        .expand((x) => x)
        .toList();
    final linesFromMergeWith = mergeWith.entries
        .map((entry) => "${entry.key}=${entry.value}")
        .toList();

    final allLines = linesFromMergeWith
      ..addAll(linesFromOverrides)
      ..addAll(linesFromFile);

    final envEntries = parser.parse(allLines);

    _envMap.addAll(envEntries);
    _isInitialized = true;
  }

  /// True if all supplied variables have nonempty value; false otherwise.
  /// Differs from [containsKey](dart:core) by excluding null values.
  /// Note [load] should be called first.
  bool isEveryDefined(Iterable<String> vars) =>
      vars.every((k) => _envMap[k]?.isNotEmpty ?? false);

  Future<List<String>> _getEntriesFromFile(String filename) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      var envString = await rootBundle.loadString(filename);
      if (envString.isEmpty) {
        throw EmptyEnvFileError();
      }
      return envString.split('\n');
    } on FlutterError {
      throw FileNotFoundError();
    }
  }

  Future<List<String>> _getLinesFromOverride(List<String> overrideWith) async {
    List<String> overrideLines = [];

    for (int i = 0; i < overrideWith.length; i++) {
      final overrideWithFile = overrideWith[i];
      final lines = await _getEntriesFromFile(overrideWithFile);
      overrideLines = overrideLines..addAll(lines);
    }

    return overrideLines;
  }
}
