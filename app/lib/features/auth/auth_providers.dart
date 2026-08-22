import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:scrutiny_core/scrutiny_core.dart';
import 'package:scrutiny_domain/scrutiny_domain.dart';

import '../../providers/repository_providers.dart';

part 'auth_providers.g.dart';

/// Relays the repository's session stream.
///
/// A thin wrapper, but it gives the rest of the app
/// a Riverpod-shaped handle on the session and a single point
/// at which to override sign-in state in tests.
@riverpod
Stream<Account?> accountChanges(Ref ref) =>
    ref.watch(authRepositoryProvider).watchAccount();

/// Combines the session with the profile it refers to.
///
/// This is the boundary at which `Result` gives way to `AsyncValue`.
/// A [Failure] is rethrown so that Riverpod captures it as an `AsyncError`,
/// leaving widgets to deal with a single error mechanism rather than two.
/// Below this line nothing throws; above it, nothing sees `Result`.
///
/// Recomputes whenever the session changes,
/// so signing out clears the profile without any explicit invalidation.
@riverpod
Future<AuthState> authState(Ref ref) async {
  final account = await ref.watch(accountChangesProvider.future);
  if (account == null) return const Unauthenticated();

  final result = await ref
      .watch(userProfileRepositoryProvider)
      .findById(account.id);

  return switch (result) {
    // `value` may be null, which `Authenticated` treats as "onboarding needed".
    Success(:final value) => Authenticated(account: account, profile: value),
    Failure(:final error) => throw error,
  };
}

/// Drives the sign-in form.
///
/// Separate from [authStateProvider] because
/// the two answer different questions:
/// this one reports the progress of an attempt,
/// that one reports who is currently signed in.
/// On success no state is set here —
/// the repository emits on its stream, [authStateProvider] recomputes,
/// and the interface follows.
/// Assigning the account to both would give it two owners.
@riverpod
class SignInController extends _$SignInController {
  @override
  FutureOr<void> build() {
    // Idle until [signIn] is called.
  }

  /// Attempts to sign in, exposing progress and failure through [state].
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();

    final result = await ref.read(signInWithEmailProvider)(
      Email(email),
      password,
    );

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final error) => AsyncError(error, StackTrace.current),
    };
  }
}
