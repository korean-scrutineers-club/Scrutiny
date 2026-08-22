// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single place where interfaces are bound to implementations.
///
/// Riverpod appears here and nowhere below:
/// `packages/data` uses constructor injection only.
/// That keeps repositories constructible in a test with one line,
/// leaves `admin` free to wire things its own way,
/// and allows the data layer to be reused outside Flutter altogether.
///
/// Moving to Supabase means editing the two bindings below.
/// Nothing in the domain or the interface changes — which is the property
/// the slice is intended to demonstrate.
/// The authentication backend.
///
/// Kept alive because sign-in state outlives any single screen;
/// disposing it would drop the session stream.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// The single place where interfaces are bound to implementations.
///
/// Riverpod appears here and nowhere below:
/// `packages/data` uses constructor injection only.
/// That keeps repositories constructible in a test with one line,
/// leaves `admin` free to wire things its own way,
/// and allows the data layer to be reused outside Flutter altogether.
///
/// Moving to Supabase means editing the two bindings below.
/// Nothing in the domain or the interface changes — which is the property
/// the slice is intended to demonstrate.
/// The authentication backend.
///
/// Kept alive because sign-in state outlives any single screen;
/// disposing it would drop the session stream.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// The single place where interfaces are bound to implementations.
  ///
  /// Riverpod appears here and nowhere below:
  /// `packages/data` uses constructor injection only.
  /// That keeps repositories constructible in a test with one line,
  /// leaves `admin` free to wire things its own way,
  /// and allows the data layer to be reused outside Flutter altogether.
  ///
  /// Moving to Supabase means editing the two bindings below.
  /// Nothing in the domain or the interface changes — which is the property
  /// the slice is intended to demonstrate.
  /// The authentication backend.
  ///
  /// Kept alive because sign-in state outlives any single screen;
  /// disposing it would drop the session stream.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'0943102941691baa4860212e83ca1fbe08f4d672';

/// Storage for user profiles.

@ProviderFor(userProfileRepository)
final userProfileRepositoryProvider = UserProfileRepositoryProvider._();

/// Storage for user profiles.

final class UserProfileRepositoryProvider
    extends
        $FunctionalProvider<
          UserProfileRepository,
          UserProfileRepository,
          UserProfileRepository
        >
    with $Provider<UserProfileRepository> {
  /// Storage for user profiles.
  UserProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserProfileRepository create(Ref ref) {
    return userProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileRepository>(value),
    );
  }
}

String _$userProfileRepositoryHash() =>
    r'de01c4b77224a4fabe53dcdf7d524b43389b2362';

/// The sign-in use case, constructed against the bound repository.

@ProviderFor(signInWithEmail)
final signInWithEmailProvider = SignInWithEmailProvider._();

/// The sign-in use case, constructed against the bound repository.

final class SignInWithEmailProvider
    extends
        $FunctionalProvider<SignInWithEmail, SignInWithEmail, SignInWithEmail>
    with $Provider<SignInWithEmail> {
  /// The sign-in use case, constructed against the bound repository.
  SignInWithEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithEmailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithEmailHash();

  @$internal
  @override
  $ProviderElement<SignInWithEmail> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInWithEmail create(Ref ref) {
    return signInWithEmail(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithEmail value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithEmail>(value),
    );
  }
}

String _$signInWithEmailHash() => r'4ce4afb4f843f8e3e1d0e2a7c64345b0a845bd76';
