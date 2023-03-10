import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data.dart';
import 'reputation_history_page.dart';
import 'user_list_page.dart';

class GreatApp extends StatelessWidget {
  final AppService? appService;

  const GreatApp({
    super.key,
    this.appService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return (appService ?? AppService()
          ..loadDataFromSharedPreferences());
      },
      child: Material(
        child: CupertinoApp(
          title: 'StackOverflow users',
          debugShowCheckedModeBanner: false,
          initialRoute: routeForUserList(),
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }
}

// We don't need a routing framework for this small app.
Route _onGenerateRoute(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '/');
  switch (uri.path) {
    case '/':
      return CupertinoPageRoute(
        settings: settings,
        builder: (context) => const UserListPage(),
      );
    case '/reputation':
      final userId = int.parse(uri.queryParameters['id'] ?? '0');
      return CupertinoPageRoute(
        settings: settings,
        builder: (context) => ReputationHistoryPage(userId: userId),
      );
    default:
      assert(false);
      return CupertinoPageRoute(
        settings: settings,
        builder: (context) => const UserListPage(),
      );
  }
}

/// Route for the user list page.
String routeForUserList() => '/';

/// Route for the user page.
String routeForUser(int userId) => '/reputation?id=$userId';
