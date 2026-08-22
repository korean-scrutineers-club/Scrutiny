// lib/src/entities/user_profile.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:scrutiny_core/scrutiny_core.dart';

part 'user_profile.freezed.dart';

/// Application-owned data about a user, stored in our own database.
///
/// The counterpart to [Account]: this is the half of a user's identity that
/// we control and may reshape freely, independently of
/// the authentication provider.
@freezed
abstract class UserProfile with _$UserProfile {
  /// Creates a profile record.
  const factory UserProfile({
    /// Shares the value of `Account.id`.
    ///
    /// Under Supabase this is a foreign key from `profiles.id` to
    /// `auth.users.id`; under Firebase, the document identifier.
    /// Reusing the identifier rather than minting a second one keeps lookups to
    /// a single key on either backend.
    required UserId id,

    /// The name shown throughout the interface.
    required String displayName,

    /// A URL for the user's avatar, absent if none has been set.
    required String? avatarUrl,

    /// When the profile was last modified.
    required DateTime updatedAt,
  }) = _UserProfile;
}
