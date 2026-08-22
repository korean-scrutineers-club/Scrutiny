import 'package:scrutiny_core/scrutiny_core.dart';

import '../entities/account.dart';
import '../repositories/auth_repository.dart';

/// Signs a user in with an email address and password.
///
/// Invoked through [call], so the instance reads as a function:
///
/// ```dart
/// final result = await signInWithEmail(Email(address), password);
/// ```
///
/// No shared `UseCase<Params, T>` interface exists yet.
/// Wait until several use cases are written and the commonality is demonstrable;
/// abstracting from a single example tends to produce the wrong abstraction.
class SignInWithEmail {
  /// Creates the use case against [_repository].
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  /// Attempts to sign in, rejecting an empty password before
  /// any request is made.
  ///
  /// Validation belongs here rather than in the widget so that
  /// it applies equally to every caller — app, admin, or test.
  Future<Result<Account>> call(Email email, String password) {
    if (password.isEmpty) {
      return Future.value(
        const Failure(AuthException('Please enter your password.')),
      );
    }

    return _repository.signInWithEmail(email, password);
  }
}
