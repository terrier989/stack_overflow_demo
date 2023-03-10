import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data.dart';

/// A simple service that manages the state of the app.
class AppService extends ChangeNotifier {
  /// "package:shared_preferences" is used to persist the state.
  /// This is the key we use.
  static const _prefsKey = 'appState';

  AppData _appData = AppData();

  // Whether the state has been loaded from the shared preferences.
  bool _hasBeenLoadedFromSharedPreferences = false;

  // Simple result cache with no expiration or size limit for successfully
  // read objects.
  final Map<String, Object?> _cache = {};

  // For saving the future.
  Future? _savingFuture;

  // Our helper for HTTP requests.
  final _dio = Dio();

  /// The app data that we persist.
  AppData get appData => _appData;

  /// Whether the state has been loaded from the shared preferences.
  bool get isInitialized => _hasBeenLoadedFromSharedPreferences;

  /// Returns reputation events of a StackOverflow user.
  Future<PagedOutput<ReputationHistoryItem>> listReputationHistoryItems({
    required int userId,
    required int page,
  }) async {
    final result = await _fetchAndParseJson(
      'https://api.stackexchange.com/2.2/users/$userId/reputation-history?page=${page + 1}&site=stackoverflow.com',
      (json) {
        return PagedOutput.fromJson(
          json,
          ReputationHistoryItem.fromJson,
        );
      },
    );
    return result;
  }

  /// Returns list of StackOverflow users.
  Future<PagedOutput<User>> listUsers({
    required int page,
    required bool showOnlyBookmarked,
  }) async {
    if (showOnlyBookmarked) {
      return PagedOutput(
        items: appData.bookmarkedUserIds
            .map((e) => appData.cachedUsers[e])
            .whereType<User>()
            .toList(),
        hasMore: false,
        quotaRemaining: 1,
      );
    }

    final result = await _fetchAndParseJson(
      'https://api.stackexchange.com/2.2/users?page=${page + 1}&site=stackoverflow.com',
      (json) {
        return PagedOutput.fromJson(
          json,
          User.fromJson,
        );
      },
    );

    // Update cached data if an user is bookmarked.
    for (var user in result.items) {
      if (appData.bookmarkedUserIds.contains(user.userId)) {
        await _mutateState((state) {
          appData.cachedUsers[user.userId] = user;
        });
      }
    }

    return result;
  }

  /// Loads [appData] from the shared preferences.
  Future<void> loadDataFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_prefsKey);
      if (rawJson != null) {
        final state = AppData.fromJson(jsonDecode(rawJson));
        _appData = state;
      }
      _hasBeenLoadedFromSharedPreferences = true;
      notifyListeners();
    } catch (error) {
      assert(false, '$error');
    } finally {
      _hasBeenLoadedFromSharedPreferences = true;
    }
  }

  /// Sets whether a StackOverflow user is bookmarked.
  Future<void> setBookmarkedState(User user, bool isBookmarked,
      {bool removeFromCache = false}) async {
    await _mutateState((state) {
      final userId = user.userId;
      if (isBookmarked) {
        // Add user to bookmarks
        if (!state.bookmarkedUserIds.contains(userId)) {
          state.bookmarkedUserIds.add(userId);
        }
        state.cachedUsers[userId] = user;
      } else {
        // Remove user from bookmarks
        state.bookmarkedUserIds.removeWhere((e) => e == userId);
      }

      // Clean up cached users, but don't remove the added/removed user.
      state.cachedUsers.removeWhere((key, value) {
        return !state.bookmarkedUserIds.contains(key) && key != userId;
      });
    });
  }

  /// Sets the currently viewed user, which will be available in
  /// [AppData.cachedUsers].
  void setCurrentUser(User user) {
    _mutateState((state) {
      // Don't cache too many
      appData.cachedUsers.removeWhere((key, value) {
        return !appData.bookmarkedUserIds.contains(key) && key != user.userId;
      });
      appData.cachedUsers[user.userId] = user;
    });
  }

  /// Sets "only bookmarked users" filter state.
  Future<void> setShowOnlyBookmarked(bool value) async {
    await _mutateState((state) {
      state.showOnlyBookmarked = value;
    });
  }

  Future<T> _fetchAndParseJson<T>(
      String url, T Function(Map<String, dynamic> json) parse) async {
    final existingResult = _cache[url];
    if (existingResult != null) {
      return existingResult as T;
    }
    final response = await _dio.get(
      url,
      options: Options(
        responseType: ResponseType.json,
        validateStatus: (status) => status != 0,
        sendTimeout: const Duration(seconds: 1),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en',
        },
      ),
    );
    final json = response.data as Map<String, dynamic>;
    final result = parse(json);
    if (response.statusCode == 200 &&
        result is PagedOutput &&
        result.quotaRemaining > 0) {
      _cache[url] = result;
    }
    return result;
  }

  /// A tiny helper for state changes.
  ///
  /// The callback will be called immediately, but the state will be saved
  /// in shared preferences after some time.
  Future<void> _mutateState(void Function(AppData state) callback) async {
    callback(appData);
    notifyListeners();

    // Don't do save too often
    final future = _savingFuture ??= () async {
      await Future.delayed(const Duration(milliseconds: 100));
      _savingFuture = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, json.encode(appData.toJson()));
    }();

    await future;
  }
}
