import 'exceptions.dart';

/// The outcome of an operation that may fail:
/// either a [Success] carrying a value of type [T],
/// or a [Failure] carrying an [AppException].
///
/// Repositories and use cases return this rather than throwing,
/// which makes failure part of each signature and
/// therefore impossible to overlook.
/// The conversion to Dart's exception machinery happens once,
/// at the presentation boundary, where a [Failure] is rethrown
/// so that Riverpod can surface it as an `AsyncError`.
///
/// Because the type is sealed, the analyser verifies that
/// every `switch` covers both cases:
///
/// ```dart
/// switch (result) {
///   case Success(:final value):
///     print(value);
///   case Failure(:final error):
///     print(error.message);
/// }
/// ```
///
/// No `fold` or `map` helpers are provided yet.
/// Add them once the pattern of use is clear from real call sites,
/// rather than guessing in advance.
sealed class Result<T> {
  /// Const constructor for subclasses.
  const Result();
}

/// A successful outcome holding [value].
final class Success<T> extends Result<T> {
  /// Wraps [value] as a successful outcome.
  const Success(this.value);

  /// The value produced by the operation.
  final T value;
}

/// A failed outcome holding [error].
final class Failure<T> extends Result<T> {
  /// Wraps [error] as a failed outcome.
  const Failure(this.error);

  /// The reason the operation did not succeed.
  final AppException error;
}
