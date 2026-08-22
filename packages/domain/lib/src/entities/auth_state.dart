import 'account.dart';
import 'user_profile.dart';

/// Whether a user is signed in, and if so what is known about them.
///
/// Sealed, so that the interface layer is obliged to handle both cases.
sealed class AuthState {
  /// Const constructor for subclasses.
  const AuthState();
}

/// No session is active.
final class Unauthenticated extends AuthState {
  /// Creates the signed-out state.
  const Unauthenticated();
}

/// A session is active.
final class Authenticated extends AuthState {
  /// Creates the signed-in state for [account], with [profile] if one exists.
  const Authenticated({required this.account, this.profile});

  /// The authenticated identity.
  final Account account;

  /// The user's profile, or `null` if none has been created.
  ///
  /// This is a routine state rather than an error:
  /// after social sign-in the profile row will not yet exist,
  /// and a `null` here is what sends the user to onboarding.
  final UserProfile? profile;
}
