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

  Future<List<String>> _loadLinesFromFile({
    required String fileName,
    bool isOptional = false,
  }) async {
    List<String> linesFromFile;
    try {
      linesFromFile = await _getEntriesFromFile(fileName);
    } on FileNotFoundError {
      if (isOptional) {
        linesFromFile = [];
      } else {
        rethrow;
      }
    }
    return linesFromFile;
  }

  /// Loads environment variables from the env file into a map
  /// Merge with any entries defined in [mergeWith]
  Future<void> load({
    String fileName = '.env',
    String? baseEnvFileName,
    Parser parser = const Parser(),
    Map<String, String> mergeWith = const {},
    bool isOptional = false,
  }) async {
    clean();
    List<String> linesFromFile =
        await _loadLinesFromFile(fileName: fileName, isOptional: isOptional);

    List<String> linesFromBaseEnvFile = [];
    if (baseEnvFileName != null) {
      linesFromBaseEnvFile = await _loadLinesFromFile(
          fileName: baseEnvFileName, isOptional: isOptional);
    }

    final baseEnvEntries = parser.parse(linesFromBaseEnvFile);
    final linesFromMergeWith = mergeWith.entries
        .map((entry) => "${entry.key}=${entry.value}")
        .toList();
    final allLines = linesFromMergeWith..addAll(linesFromFile);
    final envEntries = parser.parse(allLines);

    _envMap.addAll(baseEnvEntries);
    _envMap.addAll(envEntries);
    _isInitialized = true;
  }

  void testLoad(
      {String fileInput = '',
      Parser parser = const Parser(),
      Map<String, String> mergeWith = const {}}) {
    clean();
    final linesFromFile = fileInput.split('\n');
    final linesFromMergeWith = mergeWith.entries
        .map((entry) => "${entry.key}=${entry.value}")
        .toList();
    final allLines = linesFromMergeWith..addAll(linesFromFile);
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
}
