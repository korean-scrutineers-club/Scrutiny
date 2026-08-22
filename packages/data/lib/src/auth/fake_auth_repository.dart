import 'dart:async';

import 'package:scrutiny_core/scrutiny_core.dart';
import 'package:scrutiny_domain/scrutiny_domain.dart';

/// An in-memory [AuthRepository] for exercising the stack without a backend.
///
/// Introduced ahead of the real implementation so that
/// the vertical slice can be proved end to end before Supabase is involved.
/// Wiring the SDK in first tends to turn a question about architecture into
/// a session of debugging credentials and network configuration.
///
/// Retain this after `SupabaseAuthRepository` arrives —
/// move it under `test/fake/` and use it to drive use case tests offline.
///
/// Accepts any address; the password must be `password`.
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<Account?>.broadcast();

  /// The account for the active session, or `null` when signed out.
  Account? _current;

  @override
  Stream<Account?> watchAccount() async* {
    // Replay the present state before relaying changes,
    // so a subscriber that arrives after sign-in is not left waiting for
    // an event that has been and gone.
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<Result<Account>> signInWithEmail(Email email, String password) async {
    // A short delay so that loading indicators are actually exercised.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (password != 'password') {
      return const Failure(
        AuthException('The email address or password is incorrect.'),
      );
    }

    final account = Account(
      id: const UserId('user-001'),
      email: email,
      isEmailVerified: true,
      provider: AuthProvider.email,
      createdAt: DateTime(2026, 1, 1),
    );

    _current = account;
    _controller.add(account);

    return Success(account);
  }

  @override
  Future<Result<void>> signOut() async {
    _current = null;
    _controller.add(null);

    return const Success(null);
  }

  /// Closes the underlying stream controller.
  ///
  /// Call from a provider's `onDispose` in tests to avoid a leak between cases.
  void dispose() => _controller.close();
}
