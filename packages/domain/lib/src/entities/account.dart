import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:scrutiny_core/scrutiny_core.dart';

part 'account.freezed.dart';

/// The mechanism by which an account was authenticated.
///
/// Providers report this differently — Supabase yields `'google'`
/// where Firebase yields `'google.com'` — so the data layer normalises
/// those strings onto this enum.
/// The domain therefore stays free of provider-specific vocabulary.
enum AuthProvider {
  /// Email address and password.
  email,

  /// Google sign-in.
  google,

  /// Sign in with Apple.
  apple,

  /// A session with no credentials attached, typically for guest browsing.
  anonymous,
}

/// The authenticated identity of a user, as owned by
/// the authentication service.
///
/// Kept separate from [UserProfile] because the two have different owners and
/// different lifetimes: this record is the provider's to manage,
/// whereas the profile lives in our own database.
/// Merging them would make the state immediately after sign-up —
/// authenticated, but with no profile row yet — impossible to represent.
///
/// Tokens and session expiry are deliberately absent.
/// Those are the SDK's concern; admitting them here would leak infrastructure
/// into the domain and undermine the ability to change provider.
@freezed
abstract class Account with _$Account {
  /// Creates an account record.
  ///
  /// Every field is `required`, including the nullable ones.
  /// This is deliberate: it forces each mapper to state a value explicitly,
  /// so that adding a field to this entity breaks compilation
  /// at every mapping site rather than silently filling in a default.
  const factory Account({
    /// The provider-issued identifier. Also the primary key of the
    /// corresponding [UserProfile].
    required UserId id,

    /// The address on the account, absent for anonymous or phone-based sign-in.
    required Email? email,

    /// Whether ownership of [email] has been confirmed.
    ///
    /// Always `false` when [email] is `null`.
    required bool isEmailVerified,

    /// How this session was established.
    required AuthProvider provider,

    /// When the account was first created, as reported by the provider.
    required DateTime createdAt,
  }) = _Account;
}
