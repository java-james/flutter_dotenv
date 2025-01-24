/// Creates key-value pairs from strings formatted as environment
/// variable definitions.
class Parser {
  static const _singleQuote = "'";
  static final _leadingExport = RegExp(r'''^ *export ?''');
  static final _surroundQuotes =
      RegExp(r'''^(["'])((?:\\.|(?!\1).)*)\1''', dotAll: true);
  static final _bashVar = RegExp(r'''(\\)?(\$)(?:{)?([a-zA-Z_][\w]*)+(?:})?''');

  /// [Parser] methods are pure functions.
  const Parser();

  /// Creates a [Map](dart:core).
  /// Duplicate keys are silently discarded.
  Map<String, String> parse(Iterable<String> lines) {
    var envMap = <String, String>{};
    var linesList = lines.toList();
    var i = 0;

    while (i < linesList.length) {
      var line = linesList[i];

      // Skip comments and empty lines
      if (line.trim().startsWith('#') || line.trim().isEmpty) {
        i++;
        continue;
      }

      // Handle multi-line values
      if (line.contains('=')) {
        var parts = line.split('=');
        var key = trimExportKeyword(parts[0]).trim();
        var value = parts.sublist(1).join('=').trim();

        // Check if this is a multi-line value
        if ((value.startsWith('"') || value.startsWith("'")) &&
            !value.endsWith(value[0]) &&
            i < linesList.length - 1) {
          var quoteChar = value[0];
          var nextLine = linesList[i + 1];
          // If next line is not empty and not a key=value pair, treat as multi-line
          if (nextLine.trim().isNotEmpty && !nextLine.contains('=')) {
            var buffer = StringBuffer();
            buffer.write(value.substring(1)); // Remove leading quote
            i++;
            var lines = <String>[];
            while (i < linesList.length) {
              var currentLine = linesList[i];
              if (currentLine.trim().endsWith(quoteChar)) {
                lines.add(currentLine.substring(
                    0,
                    currentLine
                        .lastIndexOf(quoteChar))); // Remove trailing quote
                break;
              }
              lines.add(currentLine);
              i++;
            }
            // Join lines with Unix-style line endings
            value = ('$buffer\n${lines.join('\n')}')
                .replaceAll('\r\n', '\n')
                .replaceAll('\r', '\n');
          }
        }

        final parsedKeyValue = parseOne('$key=$value', envMap: envMap);
        if (parsedKeyValue.isNotEmpty) {
          envMap.putIfAbsent(key, () => parsedKeyValue.values.single);
        }
      }
      i++;
    }
    return envMap;
  }

  /// Parses a single line into a key-value pair.
  Map<String, String> parseOne(String line,
      {Map<String, String> envMap = const {}}) {
    final lineWithoutComments = removeCommentsFromLine(line);
    if (!_isStringWithEqualsChar(lineWithoutComments)) return {};

    final indexOfEquals = lineWithoutComments.indexOf('=');
    final envKey =
        trimExportKeyword(lineWithoutComments.substring(0, indexOfEquals));
    if (envKey.isEmpty) return {};

    final envValue = lineWithoutComments
        .substring(indexOfEquals + 1, lineWithoutComments.length)
        .trim();
    final quoteChar = getSurroundingQuoteCharacter(envValue);
    var envValueWithoutQuotes = removeSurroundingQuotes(envValue);
    // Add any escaped quotes
    if (quoteChar == _singleQuote) {
      envValueWithoutQuotes = envValueWithoutQuotes.replaceAll("\\'", "'");
      // Return. We don't expect any bash variables in single quoted strings
      return {envKey: envValueWithoutQuotes};
    }
    if (quoteChar == '"') {
      envValueWithoutQuotes = envValueWithoutQuotes.replaceAll('\\"', '"');
    }
    // Interpolate bash variables
    final interpolatedValue =
        interpolate(envValueWithoutQuotes, envMap).replaceAll("\\\$", "\$");
    return {envKey: interpolatedValue};
  }

  /// Substitutes $bash_vars in [val] with values from [env].
  String interpolate(String val, Map<String, String?> env) {
    // Handle variable substitution
    return val.replaceAllMapped(_bashVar, (m) {
      // If escaped with backslash, keep the $ but remove the backslash
      if (m.group(1) != null) {
        return '\$${m.group(3)}';
      }

      // Get the variable name
      final varName = m.group(3)!;

      // If the variable exists in env, substitute its value
      if (_has(env, varName)) {
        return env[varName]!;
      }

      // If variable doesn't exist, return empty string
      return '';
    });
  }

  /// If [val] is wrapped in single or double quotes, returns the quote character.
  /// Otherwise, returns the empty string.
  String getSurroundingQuoteCharacter(String val) {
    if (!_surroundQuotes.hasMatch(val)) return '';
    return _surroundQuotes.firstMatch(val)!.group(1)!;
  }

  /// Removes quotes (single or double) surrounding a value.
  String removeSurroundingQuotes(String val) {
    var trimmed = val.trim();

    // Handle values that start with a quote but don't end with one
    if (trimmed.startsWith('"') && !trimmed.endsWith('"')) {
      return trimmed;
    }
    if (trimmed.startsWith("'") && !trimmed.endsWith("'")) {
      return trimmed;
    }
    // Handle values that end with a quote but don't start with one
    if (trimmed.endsWith('"') && !trimmed.startsWith('"')) {
      return trimmed;
    }
    if (trimmed.endsWith("'") && !trimmed.startsWith("'")) {
      return trimmed;
    }

    if (!_surroundQuotes.hasMatch(trimmed)) {
      return removeCommentsFromLine(trimmed, includeQuotes: true).trim();
    }
    final match = _surroundQuotes.firstMatch(trimmed)!;
    var content = match.group(2)!;
    // Only handle newlines for double-quoted strings
    if (match.group(1) == '"') {
      content = content.replaceAll('\\n', '\n').replaceAll(RegExp(r'\r?\n'), '\n');
    }
    return content;
  }

  /// Strips comments (trailing or whole-line).
  String removeCommentsFromLine(String line, {bool includeQuotes = false}) {
    var result = line;
    // If we're including quotes in comment detection, remove everything after #
    var commentIndex = result.indexOf('#');
    if (commentIndex >= 0 && !_isInQuotes(result, commentIndex)) {
      result = result.substring(0, commentIndex);
    }
    return result.trim();
  }

  /// Checks if the character at the given index is inside quotes
  bool _isInQuotes(String str, int index) {
    var inSingleQuote = false;
    var inDoubleQuote = false;
    for (var i = 0; i < index; i++) {
      if (str[i] == '"' && !inSingleQuote) inDoubleQuote = !inDoubleQuote;
      if (str[i] == "'" && !inDoubleQuote) inSingleQuote = !inSingleQuote;
    }
    return inSingleQuote || inDoubleQuote;
  }

  /// Omits 'export' keyword.
  String trimExportKeyword(String line) =>
      line.replaceAll(_leadingExport, '').trim();

  bool _isStringWithEqualsChar(String s) => s.isNotEmpty && s.contains('=');

  /// [ null ] is a valid value in a Dart map, but the env var representation is empty string, not the string 'null'
  bool _has(Map<String, String?> map, String key) =>
      map.containsKey(key) && map[key] != null;
}
