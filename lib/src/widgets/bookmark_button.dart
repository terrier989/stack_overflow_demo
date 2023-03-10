import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stack_overflow_users/data.dart';

class BookmarkButton extends StatelessWidget {
  final User user;
  final double size;

  const BookmarkButton({
    super.key,
    this.size = 30,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(
      builder: (context, service, _) {
        final isBookmarked = service.appData.bookmarkedUserIds.contains(
          user.userId,
        );
        return CupertinoButton(
          child: Icon(
            CupertinoIcons.heart_fill,
            color: isBookmarked ? Colors.pink : Colors.grey.withOpacity(0.2),
            size: size,
          ),
          onPressed: () {
            service.setBookmarkedState(user, !isBookmarked);
          },
        );
      },
    );
  }
}
