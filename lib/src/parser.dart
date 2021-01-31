/// Creates key-value pairs from strings formatted as environment
/// variable definitions.
class Parser {
  static const _singleQuot = "'";
  static final _leadingExport = RegExp(r'''^ *export ?''');

  static final _comment = RegExp(r'''#[^'"]*$''');
  static final _commentWithQuotes = RegExp(r'''#.*$''');
  // static final _surroundQuotes = RegExp(r'''^(['"])(.*)\1$''');
  static final _surroundQuotes = RegExp(r'''^(["'])(.*?[^\\])\1''');
  static final _bashVar = RegExp(r'(?:\\)?(\$)(?:{)?([a-zA-Z_][\w]*)+(?:})?');

  /// [Parser] methods are pure functions.
  const Parser();

  /// Creates a [Map](dart:core).
  /// Duplicate keys are silently discarded.
  Map<String, String> parse(Iterable<String> lines) {
    var out = <String, String>{};
    for (var line in lines) {
      var kv = parseOne(line, env: out);
      if (kv.isEmpty) continue;
      out.putIfAbsent(kv.keys.single, () => kv.values.single);
    }
    return out;
  }

  /// Parses a single line into a key-value pair.
  Map<String, String> parseOne(String line, {Map<String, String> env = const {}}) {
    var stripped = strip(line);
    if (!_isValid(stripped)) return {};

    var idx = stripped.indexOf('=');
    var lhs = stripped.substring(0, idx);
    var k = swallow(lhs);
    if (k.isEmpty) return {};

    var rhs = stripped.substring(idx + 1, stripped.length).trim();
    var quotChar = surroundingQuote(rhs);
    var v = unquote(rhs);
    print(v);
    if (quotChar == _singleQuot) {
      return {k: v};
    }

    final interpolatedValue = interpolate(v, env);
    return {k: interpolatedValue};
  }

  /// Substitutes $bash_vars in [val] with values from [env].
  String interpolate(String val, Map<String, String> env) => val.replaceAllMapped(_bashVar, (m) {
        var k = m.group(2);
        if (!_has(env, k)) return '';
        return env[k];
      });

  /// If [val] is wrapped in single or double quotes, returns the quote character.
  /// Otherwise, returns the empty string.

  String surroundingQuote(String val) {
    if (!_surroundQuotes.hasMatch(val)) return '';
    return _surroundQuotes.firstMatch(val).group(1);
  }

  /// Removes quotes (single or double) surrounding a value.
  String unquote(String val) {
    if (!_surroundQuotes.hasMatch(val)) return strip(val, includeQuotes: true).trim();
    return _surroundQuotes.firstMatch(val).group(2);
    // val.trim().replaceFirstMapped(_surroundQuotes, (m) => m[2]); //.trim();
  }

  /// Strips comments (trailing or whole-line).
  String strip(String line, {bool includeQuotes = false}) => line.replaceAll(includeQuotes ? _commentWithQuotes : _comment, '').trim();

  /// Omits 'export' keyword.
  String swallow(String line) => line.replaceAll(_leadingExport, '').trim();

  bool _isValid(String s) => s.isNotEmpty && s.contains('=');

  /// [ null ] is a valid value in a Dart map, but the env var representation is empty string, not the string 'null'
  bool _has(Map<String, String> map, String key) => map.containsKey(key) && map[key] != null;
}
