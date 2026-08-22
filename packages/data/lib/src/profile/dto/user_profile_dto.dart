import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:scrutiny_core/scrutiny_core.dart';
import 'package:scrutiny_domain/scrutiny_domain.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

/// The wire representation of a user profile.
///
/// Mirrors the shape of the stored row rather than the shape the domain wants,
/// which is precisely why it exists: a column rename or a change of nullability
/// stops here instead of propagating into `UserProfile`.
///
/// Field names are converted to snake_case by the `field_rename: snake` setting
/// in this package's `build.yaml`, so `displayName` serialises as
/// `display_name` without an explicit `@JsonKey`.
@freezed
abstract class UserProfileDto with _$UserProfileDto {
  /// Creates a DTO, typically via [UserProfileDto.fromJson].
  const factory UserProfileDto({
    required String id,
    required String displayName,
    required String? avatarUrl,
    required DateTime updatedAt,
  }) = _UserProfileDto;

  /// Deserialises a row returned by the backend.
  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);
}

/// Conversion from the wire format to the domain entity.
///
/// Kept in the same file as the DTO on purpose. Moved to a separate `mappers/`
/// directory it would be edited only when someone remembers to open it; here,
/// adding a field to the DTO puts the mapping directly in view.
extension UserProfileDtoMapper on UserProfileDto {
  /// Converts this DTO into a [UserProfile].
  UserProfile toEntity() => UserProfile(
    id: UserId(id),
    displayName: displayName,
    avatarUrl: avatarUrl,
    updatedAt: updatedAt,
  );
}
