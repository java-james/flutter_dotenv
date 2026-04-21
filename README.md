# flutter_dotenv

[![Pub Version](https://img.shields.io/pub/v/flutter_dotenv.svg)](https://pub.dev/packages/flutter_dotenv)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Load configuration into your Flutter app from a `.env` asset file or string.

## Install

```sh
flutter pub add flutter_dotenv
```

## Quick start

**1. Create a `.env` file** in your project root:

```sh
API_URL=https://api.example.com
MAX_RETRIES=3
DEBUG=true
```

**2. Register it as an asset** in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

**3. Load and use:**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}
```

After loading, access values anywhere you import the package:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Inside a function, widget, or service — not as a top-level initializer
final apiUrl = dotenv.get('API_URL');
final retries = dotenv.getInt('MAX_RETRIES', fallback: 1);
final debug = dotenv.getBool('DEBUG', fallback: false);
```

If your `.env` file is in a subdirectory (e.g. `assets/.env`), pass `fileName: 'assets/.env'` to `load()` and register the same path in `pubspec.yaml`.

You do not need to call `WidgetsFlutterBinding.ensureInitialized()` — the library handles this internally when loading assets.

> **Tip:** Add `.env` and any environment-specific variants (e.g. `.env.staging`) to your `.gitignore` if they should not be committed.

## Security

**Do not store secrets (API keys, tokens, passwords) in your `.env` file.** Flutter assets are bundled into the app binary and can be extracted by anyone with access to the build. Values loaded by this package should be treated as public client-side configuration.

Use `.env` files for non-sensitive configuration only — API base URLs, feature flags, timeout values, and similar settings.

For guidance on securing sensitive data, see the [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/).

## Reading variables

The package exports a singleton instance named `dotenv`. Accessing any variable before calling `load()` or `loadFromString()` throws `NotInitializedError`.

Use `get()` for required values, `maybeGet()` for optional values, and `env[...]` when direct map access is preferred.

| Method | Returns | When missing |
|--------|---------|-------------|
| `dotenv.env['NAME']` | `String?` | `null` |
| `dotenv.get('NAME')` | `String` | Throws `AssertionError` |
| `dotenv.get('NAME', fallback: 'x')` | `String` | `'x'` |
| `dotenv.maybeGet('NAME')` | `String?` | `null` |
| `dotenv.maybeGet('NAME', fallback: 'x')` | `String?` | `'x'` |

> `dotenv.env` exposes the loaded key-value map directly. Treat it as read-only.

### Typed getters

Parse values directly as `int`, `double`, or `bool`:

```dart
final retries = dotenv.getInt('MAX_RETRIES', fallback: 3);
final rate    = dotenv.getDouble('RATE', fallback: 0.5);
final debug   = dotenv.getBool('DEBUG', fallback: false);
```

All typed getters throw `AssertionError` if the variable is missing and no `fallback` is provided, and `FormatException` if the value cannot be parsed. `getBool` recognises `true`, `false`, `1`, and `0` (case-insensitive).

### Validating required variables

```dart
const required = ['API_URL', 'MAX_RETRIES'];
if (!dotenv.isEveryDefined(required)) {
  throw Exception('Missing required env variables');
}
```

`isEveryDefined()` returns `true` only when every listed variable exists with a non-empty value.

## Loading

### `load()`

Load variables from a `.env` asset file:

```dart
await dotenv.load(
  fileName: '.env',
  overrideWithFiles: ['.env.staging'],
  mergeWith: {'BUILD': 'ci'},
  isOptional: false,
);
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `fileName` | `String` | `'.env'` | Asset path of the env file (must match `pubspec.yaml`). |
| `overrideWithFiles` | `List<String>` | `[]` | Additional env asset files that override the base file. |
| `mergeWith` | `Map<String, String>` | `{}` | Programmatic key-value pairs (highest precedence). |
| `isOptional` | `bool` | `false` | When `true`, missing or empty files don't throw. |
| `parser` | `Parser` | `Parser()` | Custom parser instance. |

When `isOptional` is `true`, `FileNotFoundError` and `EmptyEnvFileError` are suppressed.

### `loadFromString()`

Load variables from a string — useful for tests or in-memory configuration:

```dart
dotenv.loadFromString(envString: 'FOO=bar\nBAZ=qux');
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `envString` | `String` | `''` | The env-formatted string to parse. |
| `overrideWith` | `List<String>` | `[]` | Additional env strings that override the base string. |
| `mergeWith` | `Map<String, String>` | `{}` | Programmatic key-value pairs (highest precedence). |
| `isOptional` | `bool` | `false` | When `true`, an empty string doesn't throw. |
| `parser` | `Parser` | `Parser()` | Custom parser instance. |

When `isOptional` is `true`, `EmptyEnvFileError` is suppressed.

### Value precedence

Both `load()` and `loadFromString()` call `clean()` first, replacing any previously loaded state. The parser keeps the **first value** it sees for each key. Lines are processed in this order:

| Priority | Source |
|----------|--------|
| 1 (highest) | `mergeWith` |
| 2 | Override files / strings |
| 3 (lowest) | Base file / string |

> **Note:** `mergeWith` values cannot be overridden by the env file. If you want the `.env` file to take precedence over programmatic values, use override files instead of `mergeWith`.

### State management

| Member | Description |
|--------|-------------|
| `dotenv.isInitialized` | `true` after `load()` or `loadFromString()` completes. |
| `dotenv.clean()` | Clears all loaded variables and resets `isInitialized` to `false`. |

After `clean()`, the instance is uninitialized. Accessing values will throw `NotInitializedError` until the next `load()` or `loadFromString()`.

### Errors

| Error | Thrown when |
|-------|------------|
| `NotInitializedError` | Accessing values before calling `load()` or `loadFromString()`. |
| `FileNotFoundError` | The env file is not in the asset bundle (`load()` only). |
| `EmptyEnvFileError` | The env file or string is empty. |
| `AssertionError` | A required variable is missing and no fallback was provided. |
| `FormatException` | A typed getter can't parse the value. |

## `.env` file syntax

```sh
# Comments start with #
KEY=value
QUOTED="double quoted value"
SINGLE='single quoted value'

# Variable interpolation
BASE_URL=https://api.example.com
FULL_URL=$BASE_URL/v1
ALT_URL=${BASE_URL}/v1

# Prevent interpolation with single quotes
PRICE='$9.99'

# Newlines in double quotes
MULTI="line1\nline2"

# The export keyword is stripped automatically
export EXPORTED=hello
```

**Parsing rules:**
- Lines without `=` are ignored.
- `#` starts a comment when it appears outside quoted values.
- Double-quoted values expand `\n` to newlines and interpolate `$VAR` / `${VAR}`.
- Single-quoted values do not interpolate variables. Escaped single quotes (`\'`) are unescaped.
- Undefined variables interpolate to an empty string.
- Unquoted values are trimmed of surrounding whitespace.
- If the same key appears multiple times anywhere in the processed input, the first occurrence wins (see [value precedence](#value-precedence)).
- Leading `export` keyword is stripped.
- This is not a full shell parser. Complex shell expressions are not supported.

## Multiple environments

Layer environment-specific values over a shared base using override files:

```sh
# .env
API_URL=https://api.example.com
LOG_LEVEL=warning
```

```sh
# .env.staging
API_URL=https://staging.api.example.com
LOG_LEVEL=debug
```

```dart
await dotenv.load(overrideWithFiles: ['.env.staging']);

dotenv.get('API_URL');   // => "https://staging.api.example.com"
dotenv.get('LOG_LEVEL'); // => "debug"
```

Override files take precedence over the base file. Register all env files as assets in `pubspec.yaml`.

## Multiple instances

The package exports a pre-created singleton `dotenv` for the common case. You can also create separate instances for different configurations — each instance maintains its own independent state:

```dart
final publicConfig = DotEnv();
final featureFlags = DotEnv();

await publicConfig.load(fileName: '.env');
await featureFlags.load(fileName: '.env.features');

String apiUrl = publicConfig.get('API_URL');
bool beta = featureFlags.getBool('BETA_ENABLED', fallback: false);
```

## Merging with Platform.environment

On platforms where `dart:io` is available (mobile, desktop), you can merge system environment variables:

```dart
import 'dart:io' show Platform;

await dotenv.load(mergeWith: Platform.environment);
```

Merged values take precedence over values declared in the env file (see [value precedence](#value-precedence)). Variables in the `.env` file can reference merged values:

```sh
CLIENT_URL=https://$CLIENT_ID.dev.example.com
```

> **Note:** `Platform.environment` is not available on Flutter web.

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| `FileNotFoundError` | The file isn't registered as an asset. | Add the exact path to `flutter: assets:` in `pubspec.yaml` and restart the app. |
| `EmptyEnvFileError` | The env file or string has no content. | Add at least one `KEY=value` entry, or use `isOptional: true`. |
| `NotInitializedError` | Accessing values before loading. | Call `await dotenv.load()` in `main()` before `runApp()`. |
| `NotInitializedError` despite `load()` in `main()` | Values read in top-level initializers run before `main()`. | Move reads inside functions, widgets, or callbacks. |
| `dotenv.env['NAME']` returns `null` | Key mismatch or the file wasn't loaded. | Check for typos. Verify `load()` completed successfully. |
| `mergeWith` value not overridden by `.env` | `mergeWith` has highest precedence. | Move the value into an override file, or stop passing it via `mergeWith`. |
| Web deploy: file not found | Web servers may ignore dotfiles. | Rename the file (e.g. `env` or `config.env`) and update `fileName` and `pubspec.yaml`. |
| `FormatException` on typed getter | The value can't be parsed as the requested type. | Check the raw value with `dotenv.env['NAME']`. |

## Migration from older versions

**v5.x to v6.0:**
- `testLoad()` was renamed to `loadFromString()`.
- Empty files with `isOptional: true` no longer throw.

**v4.x to v5.0:**
- Methods moved from top-level functions into the `DotEnv` class.
- Replace `load()` with `dotenv.load()` and `env['X']` with `dotenv.env['X']`.

## Example

See the [example app](example/) for a complete working project, or browse the [API docs on pub.dev](https://pub.dev/documentation/flutter_dotenv/latest/).

## Contributing

[Issue tracker](https://github.com/java-james/flutter_dotenv/issues) — bug reports and feature requests welcome. Pull requests are welcome.

## Support

[![Sponsor on GitHub](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/java-james)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/javajames)

## License

[MIT](LICENSE)
