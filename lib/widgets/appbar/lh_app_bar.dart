import 'package:flutter/material.dart';

class LHAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String screenName;
  const LHAppBar({Key? key, required this.screenName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFECEEF4),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Color(0xFF9BADBD),
        ),
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
      title: Text(screenName),
      titleTextStyle: Theme.of(context).textTheme.headline4,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
