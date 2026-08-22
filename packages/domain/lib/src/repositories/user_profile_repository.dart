import 'package:scrutiny_core/scrutiny_core.dart';

import '../entities/user_profile.dart';

/// Persistence for application-owned user data.
abstract interface class UserProfileRepository {
  /// Retrieves the profile belonging to [id].
  ///
  /// Returns [Success](null) when no profile exists —
  /// that is an expected outcome, not a failure,
  /// and keeping it out of the error channel means
  /// onboarding logic need not be tangled up with error handling.
  /// A [Failure] here means the query itself did not complete.
  Future<Result<UserProfile?>> findById(UserId id);

  /// Inserts [profile], or replaces the existing record with
  /// the same identifier.
  ///
  /// Expressed as an upsert because the caller is rarely in a position to know
  /// whether a row already exists, and asking it to find out first would add
  /// a round trip for no benefit.
  Future<Result<UserProfile>> upsert(UserProfile profile);
}
