/// Loads environment variables from a `.env` file.
///
/// ## usage
///
/// Once you call [load] or the factory constructor with a valid env, the top-level [env] map is available.
/// You may wish to prefix the import.
///
///     import 'package:flutter_dotenv/flutter_dotenv.dart' show load, env;
///
///     void main() {
///       await DotEnv().load('.env');
///       runApp(App());
///       var x = DotEnv().env['foo'];
///       // ...
///     }
///
/// Verify required variables are present:
///
///     const _requiredEnvVars = const ['host', 'port'];
///     bool get hasEnv => isEveryDefined(_requiredEnvVars);
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

import './parser.dart';

///
/// ## usage
///
///   Future main() async {
///     await DotEnv().load('.env');
///     //...runapp
///   }
///
/// Verify required variables are present:
///
///     const _requiredEnvVars = const ['host', 'port'];
///     bool get hasEnv => isEveryDefined(_requiredEnvVars);

class DotEnv {
  Map<String, String> _env = <String, String>{};
  static DotEnv _singleton;

  Map<String, String> get env {
    if (_env.isEmpty) {
      stderr.writeln(
          '[flutter_dotenv] No env values found. Make sure you have called DotEnv.load()');
    }
    return _env;
  }

  set env(Map<String, String> env) {
    _env = env;
  }

  /// True if all supplied variables have nonempty value; false otherwise.
  /// Differs from [containsKey](dart:core) by excluding null values.
  /// Note [load] should be called first.
  bool isEveryDefined(Iterable<String> vars) =>
      vars.every((k) => env[k] != null && env[k].isNotEmpty);

  /// Read environment variables from [filename] and add them to [env].
  /// Logs to [stderr] if [filename] does not exist.
  Future load([String filename = '.env', Parser psr = const Parser()]) async {
    var lines = await _verify(filename);
    env.addAll(psr.parse(lines));
  }

  Future<List<String>> _verify(String filename) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      var str = await rootBundle.loadString(filename);
      if (str.isNotEmpty) return str.split('\n');
      stderr.writeln('[flutter_dotenv] Load failed: file $filename was empty');
    } on FlutterError {
      stderr.writeln('[flutter_dotenv] Load failed: file not found');
    }
    return [];
  }

  factory DotEnv({Map<String, String> env}) {
    if (_singleton == null) {
      _singleton = DotEnv._internal(env: env);
    }
    return _singleton;
  }

  DotEnv._internal({Map<String, String> env})
      : _env = env ?? <String, String>{};
}
