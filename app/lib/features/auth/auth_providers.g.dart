// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Relays the repository's session stream.
///
/// A thin wrapper, but it gives the rest of the app a Riverpod-shaped handle on
/// the session and a single point at which to override sign-in state in tests.

@ProviderFor(accountChanges)
final accountChangesProvider = AccountChangesProvider._();

/// Relays the repository's session stream.
///
/// A thin wrapper, but it gives the rest of the app a Riverpod-shaped handle on
/// the session and a single point at which to override sign-in state in tests.

final class AccountChangesProvider
    extends
        $FunctionalProvider<AsyncValue<Account?>, Account?, Stream<Account?>>
    with $FutureModifier<Account?>, $StreamProvider<Account?> {
  /// Relays the repository's session stream.
  ///
  /// A thin wrapper, but it gives the rest of the app a Riverpod-shaped handle on
  /// the session and a single point at which to override sign-in state in tests.
  AccountChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountChangesHash();

  @$internal
  @override
  $StreamProviderElement<Account?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Account?> create(Ref ref) {
    return accountChanges(ref);
  }
}

String _$accountChangesHash() => r'd30b3011ae27e0a1c5a18e8b30a5ad932d49d33c';

/// Combines the session with the profile it refers to.
///
/// This is the boundary at which `Result` gives way to `AsyncValue`. A
/// [Failure] is rethrown so that Riverpod captures it as an `AsyncError`,
/// leaving widgets to deal with a single error mechanism rather than two.
/// Below this line nothing throws; above it, nothing sees `Result`.
///
/// Recomputes whenever the session changes, so signing out clears the profile
/// without any explicit invalidation.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Combines the session with the profile it refers to.
///
/// This is the boundary at which `Result` gives way to `AsyncValue`. A
/// [Failure] is rethrown so that Riverpod captures it as an `AsyncError`,
/// leaving widgets to deal with a single error mechanism rather than two.
/// Below this line nothing throws; above it, nothing sees `Result`.
///
/// Recomputes whenever the session changes, so signing out clears the profile
/// without any explicit invalidation.

final class AuthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthState>,
          AuthState,
          FutureOr<AuthState>
        >
    with $FutureModifier<AuthState>, $FutureProvider<AuthState> {
  /// Combines the session with the profile it refers to.
  ///
  /// This is the boundary at which `Result` gives way to `AsyncValue`. A
  /// [Failure] is rethrown so that Riverpod captures it as an `AsyncError`,
  /// leaving widgets to deal with a single error mechanism rather than two.
  /// Below this line nothing throws; above it, nothing sees `Result`.
  ///
  /// Recomputes whenever the session changes, so signing out clears the profile
  /// without any explicit invalidation.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $FutureProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AuthState> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'adbdc56013adf8a7aa4d8ee14f4b2114b5e360b4';

/// Drives the sign-in form.
///
/// Separate from [authStateProvider] because the two answer different
/// questions: this one reports the progress of an attempt, that one reports who
/// is currently signed in. On success no state is set here — the repository
/// emits on its stream, [authStateProvider] recomputes, and the interface
/// follows. Assigning the account to both would give it two owners.

@ProviderFor(SignInController)
final signInControllerProvider = SignInControllerProvider._();

/// Drives the sign-in form.
///
/// Separate from [authStateProvider] because the two answer different
/// questions: this one reports the progress of an attempt, that one reports who
/// is currently signed in. On success no state is set here — the repository
/// emits on its stream, [authStateProvider] recomputes, and the interface
/// follows. Assigning the account to both would give it two owners.
final class SignInControllerProvider
    extends $AsyncNotifierProvider<SignInController, void> {
  /// Drives the sign-in form.
  ///
  /// Separate from [authStateProvider] because the two answer different
  /// questions: this one reports the progress of an attempt, that one reports who
  /// is currently signed in. On success no state is set here — the repository
  /// emits on its stream, [authStateProvider] recomputes, and the interface
  /// follows. Assigning the account to both would give it two owners.
  SignInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInControllerHash();

  @$internal
  @override
  SignInController create() => SignInController();
}

String _$signInControllerHash() => r'bab6743e478fd4c4ee424a42e84ef806f5727091';

/// Drives the sign-in form.
///
/// Separate from [authStateProvider] because the two answer different
/// questions: this one reports the progress of an attempt, that one reports who
/// is currently signed in. On success no state is set here — the repository
/// emits on its stream, [authStateProvider] recomputes, and the interface
/// follows. Assigning the account to both would give it two owners.

abstract class _$SignInController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
