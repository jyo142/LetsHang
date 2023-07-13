import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/notifications/notifications_bloc.dart';
import 'package:letshang/models/bottom_nav_bar.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/screens/notifications_screen.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';
import 'package:badges/badges.dart' as badges;

class LHMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String screenName;
  const LHMainAppBar({Key? key, required this.screenName}) : super(key: key);

  @override
  Widget build(BuildContext mainAppBarContext) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFCCCCCC),
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.only(left: 15),
        child: InkWell(
            onTap: () {
              BottomNavigationBarHelper.navigateToTabScreen(
                  mainAppBarContext, BottomScreenName.profile);
            },
            child: UserAvatar(
                radius: 5,
                curUser: HangUserPreview.fromUser((mainAppBarContext
                        .read<AppBloc>()
                        .state as AppAuthenticated)
                    .user))),
      ),
      actions: [
        BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            final iconButton = IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                size: 30,
                color: Color(0xFF0286BF),
              ),
              onPressed: () {
                Navigator.of(mainAppBarContext).push(
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                );
              },
            );
            if (state is PendingUserNotificationsRetrieved) {
              final badgeContent =
                  Text(state.pendingNotifications.length.toString());

              return Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: badges.Badge(
                      badgeContent: badgeContent,
                      child: iconButton,
                    ),
                    onPressed: iconButton.onPressed,
                  ));
            } else {
              return iconButton;
            }
          },
        ),
      ],
      title: Text(screenName),
      titleTextStyle: Theme.of(mainAppBarContext).textTheme.headline4,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
