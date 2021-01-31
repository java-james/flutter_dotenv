import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/src/parser.dart';

import 'errors.dart';

/// Loads environment variables from a `.env` file.
///
/// ## usage
///
/// Once you call [load], the top-level [env] map is available.
/// You may wish to prefix the import.
///
///     import 'package:dotenv/dotenv.dart' show load, env;
///
///     void main() {
///       load();
///       var x = env['foo'];
///       // ...
///     }
///
/// Verify required variables are present:
///
///     const _requiredEnvVars = const ['host', 'port'];
///     bool get hasEnv => isEveryDefined(_requiredEnvVars);
///
bool _isInitialized = false;
Map<String, String> _envMap = {};

/// A copy of variables loaded at runtime from a file + any entries from mergeWith when loaded.
Map<String, String> get env {
  if (!_isInitialized) {
    throw NotInitializedError();
  }
  return _envMap;
}

/// Clear [env]
void clean() => _envMap.clear();

/// Loads environment variables from the env file into a map
/// Merge with any entries defined in [mergeWith]
Future load({String fileName = '.env', Parser parser = const Parser(), Map<String, String> mergeWith = const {}}) async {
  clean();
  final linesFromFile = await _getEntriesFromFile(fileName);
  final linesFromMergeWith = mergeWith.entries.map((entry) => "${entry.key}=${entry.value}").toList();
  final allLines = linesFromMergeWith..addAll(linesFromFile);
  final envEntries = parser.parse(allLines);
  _envMap.addAll(envEntries);
  _isInitialized = true;
}

Future testLoad({String fileInput = '', Parser parser = const Parser(), Map<String, String> mergeWith = const {}}) async {
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
bool isEveryDefined(Iterable<String> vars) => vars.every((k) => _envMap[k] != null && _envMap[k]!.isNotEmpty);

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
