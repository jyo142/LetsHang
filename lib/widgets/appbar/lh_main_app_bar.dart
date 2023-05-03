import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/models/bottom_nav_bar.dart';
import 'package:letshang/models/hang_user_preview_model.dart';
import 'package:letshang/widgets/avatars/user_avatar.dart';

class LHMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String screenName;
  const LHMainAppBar({Key? key, required this.screenName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFCCCCCC),
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.only(left: 15),
        child: InkWell(
            onTap: () {
              BottomNavigationBarHelper.navigateToTabScreen(
                  context, BottomScreenName.profile);
            },
            child: UserAvatar(
                radius: 5,
                curUser: HangUserPreview.fromUser(
                    (context.read<AppBloc>().state as AppAuthenticated).user))),
      ),
      title: Text(screenName),
      titleTextStyle: Theme.of(context).textTheme.headline4,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
