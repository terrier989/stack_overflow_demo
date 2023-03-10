import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stack_overflow_users/src/widgets/bookmark_button.dart';
import 'package:stack_overflow_users/src/widgets/paged_widget.dart';

import '../../data.dart';

class ReputationHistoryPage extends StatelessWidget {
  final int userId;

  const ReputationHistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Users',
        middle: Text('Reputation history'),
      ),
      child: SafeArea(
        child: Consumer<AppService>(
          builder: (context, service, _) {
            final user = service.appData.cachedUsers[userId];
            return PagedWidget(
              queryParametersCopy: () => null,
              headerSliver: SliverSafeArea(
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: 1,
                    (context, i) {
                      if (i > 0 || user == null) {
                        return null;
                      }
                      final profileImage = user.profileImage;
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            profileImage.isEmpty
                                ? const SizedBox(width: 100, height: 100)
                                : Image.network(
                                    profileImage,
                                    width: 100,
                                    height: 100,
                                  ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText(
                                    user.displayName,
                                    textScaleFactor: 1.5,
                                  ),
                                  const SizedBox(height: 5),
                                  SelectableText(
                                    user.location,
                                  ),
                                  const SizedBox(height: 20),
                                  const Text('Reputation:',
                                      textScaleFactor: 0.8),
                                  SelectableText('${user.reputation}'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            BookmarkButton(user: user),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              queryFunction: (page) => service.listReputationHistoryItems(
                userId: userId,
                page: page,
              ),
              builder: (context, i, historyItem) {
                final dateTime = historyItem.createdAt;
                final dateString =
                    '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
                final postId = historyItem.postId;
                return CupertinoListTile(
                  key: ValueKey(i),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  title: Text(
                    '${historyItem.reputationChange >= 0 ? '+' : '-'} ${historyItem.reputationChange.abs()}',
                    textScaleFactor: 1.2,
                  ),
                  subtitle: Text(
                    _typeText(historyItem.reputationHistoryType),
                  ),
                  additionalInfo: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(dateString),
                      if (postId > 0) ...[
                        SelectableText('#$postId'),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _typeText(String type) {
    switch (type) {
      case 'post_upvoted':
        return 'Post upvoted';
      case 'post_unupvoted':
        return 'Post unupvoted';
      case 'post_downvoted':
        return 'Post downvoted';
      case 'post_undownvoted':
        return 'Post undownvoted';
      default:
        return 'Other';
    }
  }
}
