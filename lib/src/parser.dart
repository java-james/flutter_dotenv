import 'package:meta/meta.dart';

/// Creates key-value pairs from strings formatted as environment
/// variable definitions.
class Parser {
  static const _keyword = 'export';

  static final _comment = RegExp(r'''#.*(?:[^'"])$''');
  static final _surroundQuotes = RegExp(r'''^(['"])(.*)\1$''');

  /// [Parser] methods are pure functions.
  const Parser();

  /// Creates a [Map](dart:core)
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
  @visibleForTesting
  Map<String, String> parseOne(String line,
      {Map<String, String> env = const {}}) {
    var stripped = strip(line);
    if (!_isValid(stripped)) return {};

    var idx = stripped.indexOf('=');
    var lhs = stripped.substring(0, idx);
    var k = swallow(lhs);
    if (k.isEmpty) return {};

    var rhs = stripped.substring(idx + 1, stripped.length).trim();
    var v = unquote(rhs);

    return {k: v};
  }

  /// If [val] is wrapped in single or double quotes, returns the quote character.
  /// Otherwise, returns the empty string.
  @visibleForTesting
  String surroundingQuote(String val) {
    if (!_surroundQuotes.hasMatch(val)) return '';
    return _surroundQuotes.firstMatch(val).group(1);
  }

  /// Removes quotes (single or double) surrounding a value.
  @visibleForTesting
  String unquote(String val) =>
      val.replaceFirstMapped(_surroundQuotes, (m) => m[2]).trim();

  /// Strips comments (trailing or whole-line).
  @visibleForTesting
  String strip(String line) => line.replaceAll(_comment, '').trim();

  /// Omits 'export' keyword.
  @visibleForTesting
  String swallow(String line) => line.replaceAll(_keyword, '').trim();

  bool _isValid(String s) => s.isNotEmpty && s.contains('=');
}
