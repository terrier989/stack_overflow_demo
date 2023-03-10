import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stack_overflow_users/src/widgets/paged_widget.dart';

import '../../data.dart';
import '../../widgets.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        child: SafeArea(
          child: Consumer<AppService>(builder: (context, service, _) {
            if (!service.isInitialized) {
              return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: const [
                      Text('Loading the app...'),
                      SizedBox(height: 20),
                      CircularProgressIndicator(),
                    ],
                  ));
            }
            return PagedWidget<User>(
              // In bookmarked users list, we want to refresh the list
              // if the bookmarked state of any user changes.
              queryParametersCopy: () => service.appData.showOnlyBookmarked ?
              service.appData.bookmarkedUserIds.toSet() : null,
              queryFunction: (page) => service.listUsers(
                page: page,
                showOnlyBookmarked: service.appData.showOnlyBookmarked,
              ),
              headerSliver: SliverPersistentHeader(
                floating: true,
                delegate: _HeaderDelegate(),
              ),
              emptyBuilder: !service.appData.showOnlyBookmarked
                  ? null
                  : (context) {
                      return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          'You have no bookmarked users.',
                          textScaleFactor: 1.2,
                        ),
                      );
                    },
              builder: (context, i, user) => UserTile(
                key: ValueKey(i),
                user: user,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return OverflowBox(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 5,
        ),
        alignment: Alignment.topRight,
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          border: const Border(
            bottom: BorderSide(
              color: Colors.black12,
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('StackOverflow users'),
            Consumer<AppService>(
              builder: (context, service, widget) {
                final showOnlyBookmarked = service.appData.showOnlyBookmarked;
                return CupertinoSegmentedControl(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  children: LinkedHashMap<bool, Widget>.fromEntries([
                    const MapEntry(
                      false,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('All'),
                      ),
                    ),
                    MapEntry(
                      true,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Text('Bookmarks'),
                      ),
                    ),
                  ]),
                  groupValue: showOnlyBookmarked,
                  onValueChanged: (value) {
                    service.setShowOnlyBookmarked(value);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
