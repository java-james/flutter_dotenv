# flutter_dotenv

[![Pub Version][pub-badge]][pub]

[pub]: https://pub.dartlang.org/packages/flutter_dotenv
[pub-badge]: https://img.shields.io/pub/v/flutter_dotenv.svg

Load configuration at runtime from a `.env` file which can be used throughout the application.

> **The [twelve-factor app][12fa] stores [config][cfg] in _environment variables_**
> (often shortened to _env vars_ or _env_). Env vars are easy to change
> between deploys without changing any code... they are a language- and
> OS-agnostic standard.

[12fa]: https://www.12factor.net
[cfg]: https://12factor.net/config

# About

This library is a fork of [mockturtl/dotenv] dart library, initially with slight changes to make it work with flutter.

[mockturtl/dotenv]: https://pub.dartlang.org/packages/dotenv

An _environment_ is the set of variables known to a process (say, `PATH`, `PORT`, ...).
It is desirable to mimic the production environment during development (testing,
staging, ...) by reading these values from a file.

This library parses that file and merges its values with the built-in
[`Platform.environment`][docs-io] map.

[docs-io]: https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:io.Platform#id_environment

# Usage

1. Create a `.env` file in the root of your project with the example content:

```sh
FOO=foo
BAR=bar
FOOBAR=$FOO$BAR
ESCAPED_DOLLAR_SIGN='$1000'
```

> Note: If deploying to web server, ensure that the config file is uploaded and not ignored. (Whitelist the config file on the server, or name the config file without a leading `.`)

2. Add the `.env` file to your assets bundle in `pubspec.yaml`. **Ensure that the path corresponds to the location of the .env file!**

```yml
assets:
  - .env
```

3. Remember to add the `.env` file as an entry in your `.gitignore` if it isn't already unless you want it included in your version control.

```txt
*.env
```

4. Load the `.env` file in `main.dart`. Note that `flutter_dotenv >=5.0.0` has a slightly different syntax for consuming the DotEnv data.

**v5.0.0 and later**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// DotEnv dotenv = DotEnv() is automatically called during import.
// If you want to load multiple dotenv files or name your dotenv object differently, you can do the following and import the singleton into the relavant files:
// DotEnv another_dotenv = DotEnv()

Future main() async {
  // To load the .env file contents into dotenv.
  // NOTE: fileName defaults to .env and can be omitted in this case.
  // Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load(fileName: ".env");
  //...runapp
}
```

You can then access variables from `.env` throughout the application

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
dotenv.env['VAR_NAME'];
```

**Before v5.0.0**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

Future main() async {
  await DotEnv.load(fileName: ".env");
  //...runapp
}
```

Access env using:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
env['VAR_NAME'];
```

Optionally you could map `env` after load to a config model to access a config with types.

# Advanced usage

Refer to the `test/dotenv_test.dart` file for a better idea of the behaviour of the `.env` parser.

## Referencing

You can reference variables defined above other within `.env`:

```
  FOO=foo
  BAR=bar
  FOOBAR=$FOO$BAR
```

You can escape referencing by wrapping the value in single quotes:

```dart
ESCAPED_DOLLAR_SIGN='$1000'
```

## Merging

You can merge a map into the environment on load:

```dart
  await dotenv.load(mergeWith: { "FOO": "foo", "BAR": "bar"});
```

You can also reference these merged variables within `.env`:

```
  FOOBAR=$FOO$BAR
```

## Merge with other env files:

Useful for defining a base set of values, and overriding a subset based on environment. Env files specified first take precedence.

```env
# .env
TEST_VALUE=base-value
```

```env
# .env-staging
TEST_VALUE=staging-value
```

```dart
  await dotenv.load(fileName: ".env", overrideWith: [".env-staging"]);

  dotenv.get("TEST_VALUE") // => "staging-value"
```

## Usage with Platform Environment

The Platform.environment map can be merged into the env:

```dart
  // For example using Platform.environment that contains a CLIENT_ID entry
  await dotenv.load(mergeWith: Platform.environment);
  print(env["CLIENT_ID"]);
```

Like other merged entries described above, `.env` entries can reference these merged Platform.Environment entries if required:

```
  CLIENT_URL=https://$CLIENT_ID.dev.domain.com
```

# Discussion

Use the [issue tracker][tracker] for bug reports and feature requests.

Pull requests are welcome.

[tracker]: https://github.com/java-james/flutter_dotenv/issues

# Prior art

[flutter_dotenv]: https://pub.dartlang.org/packages/dotenv

- [mockturtl/dotenv][] (dart)
- [bkeepers/dotenv][] (ruby)
- [motdotla/dotenv][] (node)
- [theskumar/python-dotenv][] (python)
- [joho/godotenv][] (go)
- [slapresta/rust-dotenv][] (rust)
- [chandu/dotenv][] (c#)
- [tpope/lein-dotenv][], [rentpath/clj-dotenv][] (clojure)
- [mefellows/sbt-dotenv][] (scala)
- [greenspun/dotenv][] (half of common lisp)

[mockturtl/dotenv]: https://pub.dartlang.org/packages/dotenv
[bkeepers/dotenv]: https://github.com/bkeepers/dotenv
[motdotla/dotenv]: https://github.com/motdotla/dotenv
[theskumar/python-dotenv]: https://github.com/theskumar/python-dotenv
[joho/godotenv]: https://github.com/joho/godotenv
[slapresta/rust-dotenv]: https://github.com/slapresta/rust-dotenv
[chandu/dotenv]: https://github.com/Chandu/DotEnv
[tpope/lein-dotenv]: https://github.com/tpope/lein-dotenv
[rentpath/clj-dotenv]: https://github.com/rentpath/clj-dotenv
[mefellows/sbt-dotenv]: https://github.com/mefellows/sbt-dotenv
[greenspun/dotenv]: https://www.youtube.com/watch?v=pUjJU8Bbn3g

# license: [MIT](LICENSE)
