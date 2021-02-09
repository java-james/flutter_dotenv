flutter_dotenv
==============

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

Create a `.env` file in the root of your project with the example content:

```sh
FOO=foo
BAR=bar
FOOBAR=$FOO$BAR
ESCAPED_DOLLAR_SIGN='$1000'
```

Add the `.env` file to your assets bundle in `pubspec.yaml`

```yml
  assets:
    - .env
```

Optionally add the `.env` file as an entry in your `.gitignore` if it isn't already

```sh
*.env
```

Load the `.env` file in `main.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

Future main() async {
  // NOTE: The filename will default to .env and doesn't need to be defined in this case
  await DotEnv.load(fileName: ".env");
  //...runapp
}
```

You can then access variables from `.env` throughout the application

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

env['VAR_NAME'];
```

Optionally you could map `env` after load to a config model to access a config with types.

# Advanced usage

## Referencing

You can reference variables defined above other within  `.env`:

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
  await DotEnv.load(mergeWith: { "FOO": "foo", "BAR": "bar"});
```

You can also reference these merged variables within `.env`:

```
  FOOBAR=$FOO$BAR
```

## Usage with Platform Environment

The Platform.environment map can be merged into the env:

```dart
  // For example using Platform.environment that contains a CLIENT_ID entry
  await DotEnv.load(mergeWith: Platform.environment);
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
