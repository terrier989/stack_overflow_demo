import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stack_overflow_users/data.dart';

void main() {
  group('$PagedOutput:', () {
    test('fromJson(), toJson(): example #1', () {
      final testedJson = {
        "quota_remaining": 2,
        'has_more': true,
        'items': [
          {
            "user_id": 3,
          },
          {
            "user_id": 4,
          }
        ],
      };

      // Test `fromJson`
      final object = PagedOutput.fromJson(
        testedJson,
        User.fromJson,
      );
      expect(object.quotaRemaining, 2);
      expect(object.hasMore, isTrue);
      expect(object.items, hasLength(2));
      expect(object.items[0].userId, 3);
      expect(object.items[1].userId, 4);

      // Test `toJson`
      final copy = PagedOutput.fromJson(
        object.toJson(),
        User.fromJson,
      );
      expect(
        jsonEncode(copy.toJson()),
        jsonEncode(object.toJson()),
      );
    });

    test('fromJson(), toJson(): example #2', () {
      final testedJson = {
        "quota_remaining": 0,
        'has_more': 'false',
        'items': [],
      };

      // Test `fromJson`
      final object = PagedOutput.fromJson(
        testedJson,
        User.fromJson,
      );
      expect(object.quotaRemaining, 0);
      expect(object.hasMore, isFalse);
      expect(object.items, isEmpty);

      // Test `toJson`
      final copy = PagedOutput.fromJson(
        object.toJson(),
        User.fromJson,
      );
      expect(
        jsonEncode(copy.toJson()),
        jsonEncode(object.toJson()),
      );
    });
  });

  group('$User:', () {
    test('fromJson(), toJson()', () {
      final json = {
        'user_id': 2,
        'display_name': 'example name',
        'profile_image': 'example image',
      };

      final object = User.fromJson(json);
      expect(object.userId, 2);
      expect(object.displayName, 'example name');
      expect(object.profileImage, 'example image');

      // Test `toJson`
      final copy = User.fromJson(object.toJson());
      expect(
        jsonEncode(copy.toJson()),
        jsonEncode(object.toJson()),
      );
    });
  });

  group('$ReputationHistoryItem:', () {
    test('fromJson(), toJson()', () {
      final json = {
        'reputation_history_type': 'example type',
        'reputation_change': 2,
      };

      final object = ReputationHistoryItem.fromJson(json);
      expect(object.reputationHistoryType, 'example type');
      expect(object.reputationChange, 2);
    });
  });
}
