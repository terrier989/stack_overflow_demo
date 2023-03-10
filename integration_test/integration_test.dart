import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_overflow_users/data.dart';
import 'package:stack_overflow_users/src/widgets/bookmark_button.dart';
import 'package:stack_overflow_users/widgets.dart';

void _expectUserListPage(WidgetTester tester) {
  expect(find.text('StackOverflow users'), findsOneWidget);
  expect(find.text('All'), findsOneWidget);
  expect(find.text('Bookmarks'), findsOneWidget);
  expect(find.byType(UserTile), findsAtLeastNWidgets(2));
  expect(find.byType(BookmarkButton), findsAtLeastNWidgets(2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    addTearDown(() {
      sharedPreferences.clear();
    });
  });

  test('$AppService.initialize', () async {
    // Initialize and change a state value.
    {
      final appService = AppService();
      expect(appService.appData.showOnlyBookmarked, isFalse);
      await appService.loadDataFromSharedPreferences();
      expect(appService.appData.showOnlyBookmarked, isFalse);
      await appService.setShowOnlyBookmarked(true);
      await pumpEventQueue();
    }

    // Initialize again.
    // THis is we see a new value.
    {
      final appService = AppService();
      expect(appService.appData.showOnlyBookmarked, isFalse);
      await appService.loadDataFromSharedPreferences();
      expect(appService.appData.showOnlyBookmarked, isTrue);
    }
  });

  testWidgets('Go to the reputation page', (WidgetTester tester) async {
    await tester.pumpWidget(const GreatApp());
    await tester.pumpAndSettle();

    // User list page?
    _expectUserListPage(tester);

    // Tap the first user
    await tester.tap(find.byType(UserTile).first);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Reputation history page?
    expect(find.text('Reputation history'), findsOneWidget);
    expect(find.byType(BookmarkButton), findsOneWidget);

    // Tap the back button
    await tester.tap(find.bySubtype<CupertinoNavigationBarBackButton>().first);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // User list page?
    _expectUserListPage(tester);
  });

  testWidgets('Bookmark an user', (WidgetTester tester) async {
    final service = AppService();
    await tester.pumpWidget(GreatApp(
      appService: service,
    ));
    await tester.pumpAndSettle();

    // User list page?
    _expectUserListPage(tester);
    expect(service.appData.bookmarkedUserIds, isEmpty);

    // Bookmark #1
    await tester.tap(find.byType(BookmarkButton).at(0));
    await tester.pumpAndSettle();
    expect(service.appData.bookmarkedUserIds, hasLength(1));

    // Bookmark #2
    await tester.tap(find.byType(BookmarkButton).at(1));
    await tester.pumpAndSettle();
    expect(service.appData.bookmarkedUserIds, hasLength(2));

    // Test that it was saved
    await Future.delayed(const Duration(milliseconds: 500));
    final otherAppService = AppService();
    expect(otherAppService.appData.bookmarkedUserIds, isEmpty);
    await otherAppService.loadDataFromSharedPreferences();
    expect(otherAppService.appData.bookmarkedUserIds, hasLength(2));

    // Go to the bookmarked users page
    await tester.tap(find.text('Bookmarks'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.byType(UserTile), findsNWidgets(2));

    // Remove bookmark #1
    await tester.tap(find.byType(BookmarkButton).at(0));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(service.appData.bookmarkedUserIds, hasLength(1));
    expect(find.byType(UserTile), findsNWidgets(1));

    // Remove bookmark #2
    await tester.tap(find.byType(BookmarkButton).at(1));
    await tester.pumpAndSettle();
    expect(service.appData.bookmarkedUserIds, hasLength(0));
    expect(find.byType(UserTile), findsNWidgets(0));

    // User list page?
    _expectUserListPage(tester);
  });
}
