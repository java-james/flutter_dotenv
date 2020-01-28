flutter_dotenv
==============

Load configuration at runtime from a `.env` file which can be used throughout the applicaiton.

## About

This library is a fork of [mockturtl/dotenv] dart library with slight changes to make this work with flutter.
It parses the `.env` file into a map contained within a singleton which allows the variables to be used throughout your application.

[mockturtl/dotenv]: https://pub.dartlang.org/packages/dotenv

### Usage

Create a `.env` file in the root of your project with the example content:

```sh
VAR_NAME=HELLOWORLD
```

Add the `.env` file to your assets bundle in `pubspec.yaml`

```yml
  assets:
    - .env
```

Add the `.env` file as an entry in your `.gitignore` if it isn't already

```sh
assets/.env*
```

Init the DotEnv singleton in `main.dart`

```dart
Future main() async {
  await DotEnv().load('assets/.env');
  //...runapp
}
```

Access variables from `.env` throughout the applicaiton

```dart
DotEnv().env['VAR_NAME'];
```

Optionally you could map `DotEnv().env` after load to a config model to access config with types.

#### Discussion

Use the [issue tracker][tracker] for bug reports and feature requests.

Pull requests are welcome.

[tracker]: https://github.com/java-james/flutter_dotenv/issues

###### Prior art

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

###### license: [MIT](LICENSE)
