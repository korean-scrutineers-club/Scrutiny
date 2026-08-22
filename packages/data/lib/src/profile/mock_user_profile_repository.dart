import 'package:scrutiny_core/scrutiny_core.dart';
import 'package:scrutiny_domain/scrutiny_domain.dart';

import 'dto/user_profile_dto.dart';

/// An in-memory [UserProfileRepository], the counterpart to
/// `MockAuthRepository`.
///
/// Stores DTOs rather than entities so that the mapping is
/// genuinely exercised on every read. Holding entities directly would leave
/// `toEntity` untested and defeat much of the point of the exercise.
///
/// Seeded with a profile for `user-001`, matching the account
/// `MockAuthRepository` issues.
class MockUserProfileRepository implements UserProfileRepository {
  final _store = <String, UserProfileDto>{
    'user-001': UserProfileDto(
      id: 'user-001',
      displayName: 'Hong Gil-dong',
      avatarUrl: null,
      updatedAt: DateTime(2026, 8, 1),
    ),
  };

  @override
  Future<Result<UserProfile?>> findById(UserId id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Absence is reported as a successful lookup of nothing. Remove the seeded
    // entry above to see the onboarding branch taken.
    return Success(_store[id.value]?.toEntity());
  }

  @override
  Future<Result<UserProfile>> upsert(UserProfile profile) async {
    _store[profile.id.value] = UserProfileDto(
      id: profile.id.value,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
      // Stamped here rather than trusting the caller, mirroring what a database
      // trigger would do.
      updatedAt: DateTime.now(),
    );
    return Success(profile);
  }
}
