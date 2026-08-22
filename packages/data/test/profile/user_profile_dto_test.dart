import 'package:test/test.dart';

import 'package:scrutiny_core/scrutiny_core.dart';
import 'package:scrutiny_data/scrutiny_data.dart';

void main() {
  group('UserProfileDto', () {
    test('round-trips snake_case JSON and maps onto the entity', () {
      final json = {
        'id': 'user-001',
        'display_name': 'Hong Gil-dong',
        'avatar_url': 'https://example.com/avatar.png',
        'updated_at': '2026-08-01T00:00:00.000Z',
      };

      final entity = UserProfileDto.fromJson(json).toEntity();

      expect(entity.id, const UserId('user-001'));
      expect(entity.displayName, 'Hong Gil-dong');
      expect(entity.avatarUrl, 'https://example.com/avatar.png');
      expect(entity.updatedAt, DateTime.parse('2026-08-01T00:00:00.000Z'));
    });

    test('maps a null avatar_url onto a null avatarUrl', () {
      final json = {
        'id': 'user-002',
        'display_name': 'Kim Yuna',
        'avatar_url': null,
        'updated_at': '2026-08-01T00:00:00.000Z',
      };

      final entity = UserProfileDto.fromJson(json).toEntity();

      expect(entity.avatarUrl, isNull);
    });
  });
}
