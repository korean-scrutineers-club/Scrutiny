import 'package:scrutiny_core/scrutiny_core.dart';

import '../entities/account.dart';

/// Access to the authentication provider, expressed without reference to
/// any particular one.
///
/// Implementations live in `packages/data` and are named after their backend —
/// `SupabaseAuthRepository`, `FirebaseAuthRepository` —
/// so that several may coexist and be selected during wiring.
///
/// The single rule that keeps this interface honest: `packages/domain` must
/// never declare a dependency on `supabase_flutter` or any other SDK.
/// Enforce that in the pubspec and the compiler enforces the rest.
abstract interface class AuthRepository {
  /// Emits the current account, then every subsequent change to it.
  ///
  /// A stream rather than a one-off read because sessions end for reasons
  /// the app does not initiate — token expiry, sign-out on another device,
  /// a revoked credential. Both Supabase's `onAuthStateChange` and
  /// Firebase's `authStateChanges()` map onto this directly.
  ///
  /// Emits `null` whenever no session is active.
  Stream<Account?> watchAccount();

  /// Signs in with [email] and [password].
  ///
  /// Returns a [Failure] holding an `AuthException`
  /// if the credentials are rejected,
  /// or a `NetworkException` if the request could not be completed.
  Future<Result<Account>> signInWithEmail(Email email, String password);

  /// Ends the current session.
  ///
  /// Succeeds even when no session is active.
  Future<Result<void>> signOut();
}
