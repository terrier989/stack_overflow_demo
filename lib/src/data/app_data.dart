import '../../data.dart';

/// An immutable object for application user's data.
class AppData {
  /// Whether only bookmarked users are shown.
  bool showOnlyBookmarked = false;

  /// IDs of bookmarked users, in the order of bookmarks.
  final List<int> bookmarkedUserIds = [];

  /// We cache bookmarked users.
  final Map<int, User> cachedUsers = {};

  AppData();

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData()
      ..showOnlyBookmarked = (json['showOnlyBookmarked'] ?? false) as bool
      ..bookmarkedUserIds.addAll(
          ((json['bookmarkedUserIds'] ?? const []) as List).whereType<int>())
      ..cachedUsers.addAll(
        ((json['cachedUsers'] ?? const <String, dynamic>{}) as Map)
            .map<int, User>(
          (key, value) => MapEntry(
            int.parse(key as String),
            User.fromJson(value as Map<String, dynamic>),
          ),
        ),
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'showOnlyBookmarked': showOnlyBookmarked,
      'bookmarkedUserIds': bookmarkedUserIds,
      'cachedUsers': cachedUsers.map(
        (key, value) => MapEntry(key.toString(), value.toJson()),
      ),
    };
  }
}
