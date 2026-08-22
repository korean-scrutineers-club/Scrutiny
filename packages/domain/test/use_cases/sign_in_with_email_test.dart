import 'package:test/test.dart';

import 'package:scrutiny_core/scrutiny_core.dart';
import 'package:scrutiny_domain/scrutiny_domain.dart';

/// A hand-written stub, not a mock: it returns [_result] when told to and
/// otherwise does nothing, which is all [SignInWithEmail] needs from it.
class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository([this._result]);

  final Result<Account>? _result;

  /// Whether [signInWithEmail] was reached.
  bool signInWithEmailCalled = false;

  @override
  Stream<Account?> watchAccount() => const Stream.empty();

  @override
  Future<Result<Account>> signInWithEmail(Email email, String password) async {
    signInWithEmailCalled = true;
    return _result!;
  }

  @override
  Future<Result<void>> signOut() async => const Success(null);
}

void main() {
  group('SignInWithEmail', () {
    test('rejects an empty password without reaching the repository', () async {
      final repository = _StubAuthRepository();
      final signIn = SignInWithEmail(repository);

      final result = await signIn(const Email('driver@example.com'), '');

      expect(result, isA<Failure<Account>>());
      expect(repository.signInWithEmailCalled, isFalse);
    });

    test('returns the account the repository produces on success', () async {
      final account = Account(
        id: const UserId('user-001'),
        email: const Email('driver@example.com'),
        isEmailVerified: true,
        provider: AuthProvider.email,
        createdAt: DateTime(2026, 1, 1),
      );
      final repository = _StubAuthRepository(Success(account));
      final signIn = SignInWithEmail(repository);

      final result = await signIn(const Email('driver@example.com'), 'password');

      expect(result, isA<Success<Account>>());
      expect((result as Success<Account>).value, account);
      expect(repository.signInWithEmailCalled, isTrue);
    });
  });
}
