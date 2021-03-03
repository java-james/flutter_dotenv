changelog
=========

This project follows [pub-flavored semantic versioning][pub-semver]. ([more][pub-semver-readme])

Release notes are available on [github][notes].

[pub-semver]: https://www.dartlang.org/tools/pub/versioning.html#semantic-versions
[pub-semver-readme]: https://pub.dartlang.org/packages/pub_semver
[notes]: https://github.com/java-james/flutter_dotenv/releases

4.0.0-nullsafety.0
-----

- [BREAKING] Opt into null-safety
- [deps] Upgrade dart sdk constraints to ```>=2.12.0-0 <3.0.0```
- [new] Allow for escape of $ ' " and \n characters
- [fix] Ensure swallow function only removes leading 'export' keyword
- [fix] Retain spaces within single or double quotes
- [fix] Allow for comments after matching end quotes
- [new] Migrate to null safety
- [new] Create unit test cases for parse


#### 3.1.0

- [new] Allow merging with a custom map on load

#### 3.0.2

- [chore] Format code with dart fmt

#### 3.0.1

- [docs] Use secure links

#### 3.0.0

- [new] Merge with Platform.Environment
- [new] Throw precise errors
- [new] Access via functions
- [new] Improved Parsing
- [docs] Example project

#### 2.1.0

- [new] Support '=' sign in value

#### 2.0.3

- [fix] Warning when using with flutter_test

#### 2.0.2

- [fix] Flutter 1.9.5 compatibility ensure binding was initialized  

#### 2.0.1

- [docs] tweak app description
- [fix] increase meta version range

2.0.0
-----

- Flutter compatible

1.0.0
-----

- Dart 2 compatible. [#16][]

#### 0.1.3+3

- [docs] tweak README

#### 0.1.3+2

- [fix] don't throw if load fails [#11][]

#### 0.1.3+1

- [fix] allow braces with `${var}` substitution [#10][]

0.1.3
-----

- [new] add command-line interface [#7][], [#8][]
- [deps] add [args][]@v0.13

[args]: https://pub.dartlang.org/packages/args

0.1.2
-----

- [new] support variable substitution from `Platform.environment` [#6][]
- [deps] drop [logging][]

#### 0.1.1+2

- [fix] don't strip `#` inside quotes [#5][]

#### 0.1.1+1

- [fix] whitespace causes quotes not to be stripped

0.1.1
-----

- [deprecated] `Parser` internals will become private. [#3][]
    - `#unquote`, `#strip`, `#swallow`, `#parseOne`, `#surroundingQuote`, `#interpolate`
- [new] support variable substitution
- [deps] migrate to [test][]
- [deps] bump [logging][]

[test]: https://pub.dartlang.org/packages/test
[logging]: https://pub.dartlang.org/packages/logging

0.1.0
-----

Initial release.
