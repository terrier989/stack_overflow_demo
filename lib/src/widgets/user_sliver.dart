import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:stack_overflow_users/src/widgets/bookmark_button.dart';

import '../../data.dart';
import '../../widgets.dart';

class UserTile extends StatelessWidget {
  final User user;

  const UserTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(builder: (context, service, widget) {
      final user = this.user;
      final userId = user.userId;
      final age = user.age;
      final location = user.location;
      return CupertinoListTile(
        onTap: () {
          // It would be nice to display user name and photo in the reputation
          // page, but the assignment didn't indicate that we are allowed use
          // some API that fetches user data by userID.
          // We could pass the data to the route directly or cache it. We chose
          // the latter.
          service.setCurrentUser(user);

          // Navigate.
          Navigator.of(context).restorablePushNamed(routeForUser(userId));
        },
        leading: Image.network(user.profileImage),
        title: Text(user.displayName),
        subtitle: Text(
          [
            if (age != null && age > 0) '$age years old',
            if (location.isNotEmpty) location,
          ].where((element) => element.isNotEmpty).join(', '),
        ),
        trailing: SizedBox(
          width: 100,
          child: BookmarkButton(
            user: user,
            size: 20,
          ),
        ),
      );
    });
  }
}
