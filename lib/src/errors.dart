class NotInitializedError extends Error {
  @override
  String toString() =>
      'NotInitializedError: DotEnv has not been initialized. '
      'Call load() or loadFromString() before accessing env variables.';
}

class FileNotFoundError extends Error {
  final String? filename;
  FileNotFoundError([this.filename]);

  @override
  String toString() => filename != null
      ? 'FileNotFoundError: Environment file "$filename" not found. '
          'Ensure the file exists and is listed under assets in pubspec.yaml.'
      : 'FileNotFoundError: Environment file not found. '
          'Ensure the file exists and is listed under assets in pubspec.yaml.';
}

class EmptyEnvFileError extends Error {
  final String? filename;
  EmptyEnvFileError({this.filename});

  @override
  String toString() => filename != null
      ? 'EmptyEnvFileError: Environment file "$filename" is empty.'
      : 'EmptyEnvFileError: The provided env string is empty.';
}
