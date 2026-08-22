import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:scrutiny_core/scrutiny_core.dart';
import 'package:scrutiny_domain/scrutiny_domain.dart';

import 'dto/user_profile_dto.dart';

/// [UserProfileRepository] backed by the `profiles` table.
///
/// Takes its [supabase.SupabaseClient] through the constructor rather than
/// reaching for `Supabase.instance.client` directly, so a test can supply
/// a client of its own instead of the process-wide singleton.
class SupabaseUserProfileRepository implements UserProfileRepository {
  /// Creates a repository backed by [_client].
  SupabaseUserProfileRepository(this._client);

  final supabase.SupabaseClient _client;

  @override
  Future<Result<UserProfile?>> findById(UserId id) async {
    try {
      // `maybeSingle` reports absence as `null` rather than throwing,
      // so a profile that has not been created yet is a successful lookup of
      // nothing, not a failure. See `UserProfileRepository.findById`.
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', id.value)
          .maybeSingle();

      if (row == null) {
        return const Success(null);
      }

      return Success(UserProfileDto.fromJson(row).toEntity());
    } on supabase.PostgrestException catch (error) {
      return Failure(UnknownException(error.message));
    } catch (_) {
      return const Failure(UnknownException());
    }
  }

  @override
  Future<Result<UserProfile>> upsert(UserProfile profile) async {
    try {
      // `updated_at` is excluded: a database trigger stamps it, mirroring
      // what `FakeUserProfileRepository` does by hand.
      final row = await _client
          .from('profiles')
          .upsert({
            'id': profile.id.value,
            'display_name': profile.displayName,
            'avatar_url': profile.avatarUrl,
          })
          .select()
          .single();

      return Success(UserProfileDto.fromJson(row).toEntity());
    } on supabase.PostgrestException catch (error) {
      return Failure(UnknownException(error.message));
    } catch (_) {
      return const Failure(UnknownException());
    }
  }
}
