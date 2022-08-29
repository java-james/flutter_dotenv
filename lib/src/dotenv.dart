import 'dart:async';

import 'package:flutter/foundation.dart';
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
    assert(value != null, 'A non-null fallback is required for missing entries');
    return value!;
  }

  String? maybeGet(String name, {String? fallback}) => env[name] ?? fallback;

  /// Loads environment variables from the env file into a map
  /// Merge with any entries defined in [mergeWith]
  Future<void> load({
    String fileName = '.env',
    Parser parser = const Parser(),
    Map<String, String> mergeWith = const {},
    String? packageName,
  }) async {
    clean();
    final linesFromFile = await _getEntriesFromFile(fileName, packageName: packageName);
    final linesFromMergeWith = mergeWith.entries.map((entry) => "${entry.key}=${entry.value}").toList();
    final allLines = linesFromMergeWith..addAll(linesFromFile);
    final envEntries = parser.parse(allLines);
    _envMap.addAll(envEntries);
    _isInitialized = true;
  }

  void testLoad({String fileInput = '', Parser parser = const Parser(), Map<String, String> mergeWith = const {}}) {
    clean();
    final linesFromFile = fileInput.split('\n');
    final linesFromMergeWith = mergeWith.entries.map((entry) => "${entry.key}=${entry.value}").toList();
    final allLines = linesFromMergeWith..addAll(linesFromFile);
    final envEntries = parser.parse(allLines);
    _envMap.addAll(envEntries);
    _isInitialized = true;
  }

  /// True if all supplied variables have nonempty value; false otherwise.
  /// Differs from [containsKey](dart:core) by excluding null values.
  /// Note [load] should be called first.
  bool isEveryDefined(Iterable<String> vars) => vars.every((k) => _envMap[k]?.isNotEmpty ?? false);

  Future<List<String>> _getEntriesFromFile(String filename, {String? packageName}) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final keyToLoad = packageName == null ? filename : 'packages/$packageName/$filename';
      var envString = await rootBundle.loadString(keyToLoad);
      if (envString.isEmpty) {
        throw EmptyEnvFileError();
      }
      return envString.split('\n');
    } on FlutterError {
      throw FileNotFoundError();
    }
  }
}
