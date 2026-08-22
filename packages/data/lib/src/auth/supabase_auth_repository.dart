import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:scrutiny_core/scrutiny_core.dart';
import 'package:scrutiny_domain/scrutiny_domain.dart';

/// [AuthRepository] backed by Supabase Auth.
///
/// Takes its [supabase.SupabaseClient] through the constructor rather than
/// reaching for `Supabase.instance.client` directly, so a test can supply
/// a client of its own instead of the process-wide singleton.
class SupabaseAuthRepository implements AuthRepository {
  /// Creates a repository backed by [_client].
  SupabaseAuthRepository(this._client);

  final supabase.SupabaseClient _client;

  @override
  Stream<Account?> watchAccount() async* {
    // Replay the present state before relaying changes,
    // so a subscriber that arrives after sign-in is not left waiting for
    // an event that has been and gone.
    yield _client.auth.currentSession?.user.toAccount();
    yield* _client.auth.onAuthStateChange.map(
      (state) => state.session?.user.toAccount(),
    );
  }

  @override
  Future<Result<Account>> signInWithEmail(Email email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.value,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Failure(AuthException());
      }

      return Success(user.toAccount());
    } on supabase.AuthRetryableFetchException {
      return const Failure(NetworkException());
    } on supabase.AuthException catch (error) {
      return Failure(AuthException(error.message));
    } catch (_) {
      return const Failure(UnknownException());
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Success(null);
    } on supabase.AuthRetryableFetchException {
      return const Failure(NetworkException());
    } on supabase.AuthException catch (error) {
      return Failure(AuthException(error.message));
    } catch (_) {
      return const Failure(UnknownException());
    }
  }
}

/// Conversion from the SDK's user record to the domain entity.
///
/// Kept in the same file as the repository that produces it, matching the
/// convention `data` uses for DTO mapping extensions.
extension SupabaseUserMapper on supabase.User {
  /// Converts this user into an [Account].
  Account toAccount() => Account(
    id: UserId(id),
    email: email == null ? null : Email(email!),
    isEmailVerified: emailConfirmedAt != null,
    provider: _authProviderFrom(appMetadata),
    createdAt: DateTime.parse(createdAt),
  );
}

/// Reads Supabase's `app_metadata.provider` string and normalises it onto
/// [AuthProvider].
///
/// Supabase reports `'email'`, `'google'` and `'apple'` for credentialed
/// sign-in, and `'anonymous'` for an anonymous session. Anything else —
/// including an absent key — falls back to [AuthProvider.anonymous]
/// rather than throwing, since this reads untrusted data
/// crossing the SDK boundary.
AuthProvider _authProviderFrom(Map<String, dynamic> appMetadata) =>
    switch (appMetadata['provider']) {
      'email' => AuthProvider.email,
      'google' => AuthProvider.google,
      'apple' => AuthProvider.apple,
      _ => AuthProvider.anonymous,
    };
