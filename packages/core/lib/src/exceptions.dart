/// The root of every error the domain layer is permitted to describe.
///
/// Deliberately sealed, so that exhaustive `switch` statements over failures
/// are checked at compile time. Infrastructure exceptions -
/// `PostgrestException`, `DioException`, `FirebaseAuthException` —
/// are translated into one of these
/// subtypes at the repository boundary and never escape the data layer.
sealed class AppException implements Exception {
  /// Creates an exception carrying a user-facing [message].
  const AppException(this.message);

  /// A message suitable for display without further processing.
  ///
  /// Diagnostic detail belongs in logs, not here.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Raised when a request could not reach the server, or timed out.
final class NetworkException extends AppException {
  /// Creates a network failure, optionally overriding the default [message].
  const NetworkException([super.message = 'A network error occurred.']);
}

/// Raised when credentials are rejected, or a session is no longer valid.
final class AuthException extends AppException {
  /// Creates an authentication failure, optionally overriding [message].
  const AuthException([super.message = 'Authentication failed.']);
}

/// Raised when a requested record genuinely does not exist.
///
/// Do not use this for the ordinary "not yet created" case —
/// a lookup that may legitimately find nothing should return
/// a nullable value inside [Success] instead.
/// See `UserProfileRepository.findById`.
final class NotFoundException extends AppException {
  /// Creates a not-found failure, optionally overriding [message].
  const NotFoundException([
    super.message = 'The requested data was not found.',
  ]);
}

/// A catch-all for failures that could not be classified.
///
/// Its appearance in logs usually signals a gap in the mapping
/// performed by a repository implementation.
final class UnknownException extends AppException {
  /// Creates an unclassified failure, optionally overriding [message].
  const UnknownException([super.message = 'An unexpected error occurred.']);
}
