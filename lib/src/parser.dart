/// Creates key-value pairs from strings formatted as environment
/// variable definitions.
class Parser {
  static const _singleQuote = "'";
  static final _leadingExport = RegExp(r'''^ *export ?''');
  static final _comment = RegExp(r'''#[^'"]*$''');
  static final _commentWithQuotes = RegExp(r'''#.*$''');
  static final _surroundQuotes = RegExp(r'''^(["'])(.*?[^\\])\1''');
  static final _bashVar = RegExp(r'''(\\)?(\$)(?:{)?([a-zA-Z_][\w]*)+(?:})?''');

  /// [Parser] methods are pure functions.
  const Parser();

  /// Creates a [Map](dart:core).
  /// Duplicate keys are silently discarded.
  Map<String, String> parse(Iterable<String> lines) {
    var envMap = <String, String>{};
    for (var line in lines) {
      final parsedKeyValue = parseOne(line, envMap: envMap);
      if (parsedKeyValue.isEmpty) continue;
      envMap.putIfAbsent(parsedKeyValue.keys.single, () => parsedKeyValue.values.single);
    }
    return envMap;
  }

  /// Parses a single line into a key-value pair.
  Map<String, String> parseOne(String line,
      {Map<String, String> envMap = const {}}) {
    final lineWithoutComments = removeCommentsFromLine(line);
    if (!_isStringWithEqualsChar(lineWithoutComments)) return {};

    final indexOfEquals = lineWithoutComments.indexOf('=');
    final envKey = trimExportKeyword(lineWithoutComments.substring(0, indexOfEquals));
    if (envKey.isEmpty) return {};

    final envValue = lineWithoutComments.substring(indexOfEquals + 1, lineWithoutComments.length).trim();
    final quoteChar = getSurroundingQuoteCharacter(envValue);
    var envValueWithoutQuotes = removeSurroundingQuotes(envValue);
    // Add any escapted quotes
    if (quoteChar == _singleQuote) {
      envValueWithoutQuotes = envValueWithoutQuotes.replaceAll("\\'", "'");
      // Return. We don't expect any bash variables in single quoted strings
      return {envKey: envValueWithoutQuotes};
    }
    if (quoteChar == '"') {
      envValueWithoutQuotes = envValueWithoutQuotes.replaceAll('\\"', '"').replaceAll('\\n', '\n');
    }
    // Interpolate bash variables
    final interpolatedValue = interpolate(envValueWithoutQuotes, envMap).replaceAll("\\\$", "\$");
    return {envKey: interpolatedValue};
  }

  /// Substitutes $bash_vars in [val] with values from [env].
  String interpolate(String val, Map<String, String?> env) =>
      val.replaceAllMapped(_bashVar, (m) {
        if ((m.group(1) ?? "") == "\\") {
          return m.input.substring(m.start, m.end);
        } else {
          final k = m.group(3)!;
          if (!_has(env, k)) return '';
          return env[k]!;
        }
      });

  /// If [val] is wrapped in single or double quotes, returns the quote character.
  /// Otherwise, returns the empty string.
  String getSurroundingQuoteCharacter(String val) {
    if (!_surroundQuotes.hasMatch(val)) return '';
    return _surroundQuotes.firstMatch(val)!.group(1)!;
  }

  /// Removes quotes (single or double) surrounding a value.
  String removeSurroundingQuotes(String val) {
    if (!_surroundQuotes.hasMatch(val)) {
      return removeCommentsFromLine(val, includeQuotes: true).trim();
    }
    return _surroundQuotes.firstMatch(val)!.group(2)!;
  }

  /// Strips comments (trailing or whole-line).
  String removeCommentsFromLine(String line, {bool includeQuotes = false}) =>
      line.replaceAll(includeQuotes ? _commentWithQuotes : _comment, '').trim();

  /// Omits 'export' keyword.
  String trimExportKeyword(String line) => line.replaceAll(_leadingExport, '').trim();

  bool _isStringWithEqualsChar(String s) => s.isNotEmpty && s.contains('=');

  /// [ null ] is a valid value in a Dart map, but the env var representation is empty string, not the string 'null'
  bool _has(Map<String, String?> map, String key) =>
      map.containsKey(key) && map[key] != null;
}
