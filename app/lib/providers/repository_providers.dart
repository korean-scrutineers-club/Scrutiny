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
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:scrutiny_domain/scrutiny_domain.dart';
import 'package:scrutiny_data/scrutiny_data.dart';

part 'repository_providers.g.dart';

/// The authentication backend.
///
/// Kept alive because sign-in state outlives any single screen;
/// disposing it would drop the session stream.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => MockAuthRepository();

/// Storage for user profiles.
@Riverpod(keepAlive: true)
UserProfileRepository userProfileRepository(Ref ref) =>
    MockUserProfileRepository();

/// The sign-in use case, constructed against the bound repository.
@riverpod
SignInWithEmail signInWithEmail(Ref ref) =>
    SignInWithEmail(ref.watch(authRepositoryProvider));
