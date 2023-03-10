/// A simple wrapper for a page of query results.
class PagedOutput<T> {
  /// The items in the page.
  final List<T> items;

  /// Whether more items may be available.
  final bool hasMore;

  /// Remaining request quota.
  final int quotaRemaining;

  PagedOutput({
    required this.items,
    this.hasMore = false,
    this.quotaRemaining = 0,
  });

  factory PagedOutput.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PagedOutput(
      items: _prop(json, 'items', [])
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(),
      hasMore: _prop(json, 'has_more', false),
      quotaRemaining: _prop(json, 'quota_remaining', 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => (e as dynamic).toJson()).toList(),
      'has_more': hasMore,
      'quota_remaining': quotaRemaining,
    };
  }
}

/// An item in a StackOverflow user's reputation history.
class ReputationHistoryItem {
  final String reputationHistoryType;
  final int reputationChange;
  final DateTime createdAt;
  final int postId;

  ReputationHistoryItem({
    required this.reputationHistoryType,
    required this.reputationChange,
    required this.createdAt,
    required this.postId,
  });

  factory ReputationHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReputationHistoryItem(
      reputationHistoryType: _prop(json, 'reputation_history_type', ''),
      reputationChange: _prop<num>(json, 'reputation_change', 0).toInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        1000 * _prop(json, 'creation_date', 0),
      ),
      postId: _prop(json, 'post_id', -1),
    );
  }
}

/// A StackOverflow user.
class User {
  final int userId;
  final String displayName;
  final String profileImage;
  final int reputation;
  final String location;
  final int? age;

  User({
    required this.userId,
    required this.displayName,
    required this.profileImage,
    required this.reputation,
    required this.location,
    required this.age,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: _prop(json, 'user_id', -1),
      displayName: _unescape(_prop(json, 'display_name', '')),
      profileImage: _prop(json, 'profile_image', ''),
      reputation: _prop<num>(json, 'reputation', 0).toInt(),
      location: _prop(json, 'location', ''),
      age: _prop<num>(json, 'location', 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'profile_image': profileImage,
      'reputation': reputation,
      'location': location,
      'age': age,
    };
  }
}

/// A quickly written helper to unescape HTML entity character codes such as
/// "&#123;" that seem to appear in the data.
String _unescape(String s) {
  final sb = StringBuffer();
  var start = 0;
  while (true) {
    final i = s.indexOf('&#', start);
    if (i < 0) {
      sb.write(s.substring(start));
      break;
    }
    final j = s.indexOf(';', i + 2);
    if (j < 0) {
      sb.write(s.substring(start));
      break;
    }
    sb.write(s.substring(start, i));
    var v = int.tryParse(s.substring(i + 2, j));
    if (v != null && v >= 32) {
      try {
        sb.writeCharCode(v);
      } catch (error) {}
    }
    start = j + 1;
  }
  return sb.toString();
}

/// A helper to get a property from a map, with a fallback value.
T _prop<T>(Map<String, dynamic> map, String property, T fallbackValue) {
  final value = map[property];
  if (value is T) {
    return value;
  }
  return fallbackValue;
}
