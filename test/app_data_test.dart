import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stack_overflow_users/data.dart';

void main() {
  group('$AppData:', () {
    test('$AppData()', () {
      final object = AppData();
      expect(object.showOnlyBookmarked, isFalse);
      expect(object.bookmarkedUserIds, isEmpty);
      expect(object.cachedUsers, isEmpty);
    });

    test('fromJson(), toJson()', () {
      final testedJson = {
        'showOnlyBookmarked': true,
        'bookmarkedUserIds': [2, 3],
        'cachedUsers': {
          '2': {
            'user_id': 1,
          },
          '3': {
            'user_id': 2,
          },
        },
      };

      // Test `fromJson`
      final object = AppData.fromJson(testedJson);
      expect(object.showOnlyBookmarked, isTrue);
      expect(object.bookmarkedUserIds, [2, 3]);
      expect(object.cachedUsers, hasLength(2));
      expect(object.cachedUsers[2]!.userId, 1);
      expect(object.cachedUsers[3]!.userId, 2);

      // Test `toJson`
      final copy = AppData.fromJson(object.toJson());
      expect(
        jsonEncode(copy.toJson()),
        jsonEncode(object.toJson()),
      );
    });
  });
}
