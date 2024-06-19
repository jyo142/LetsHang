import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';

class GroupDetailsFAB extends StatelessWidget {
  final String groupId;
  const GroupDetailsFAB({Key? key, required this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: const Color(0xFF0287BF),
      // animatedIcon: AnimatedIcons.menu_close,
      // animatedIconTheme: IconThemeData(size: 22.0),
      // / This is ignored if animatedIcon is non null
      // child: Text("open"),
      // activeChild: Text("close"),
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      foregroundColor: Colors.white,

      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,

      /// Transition Builder between label and activeLabel, defaults to FadeTransition.
      // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
      /// The below button size defaults to 56 itself, its the SpeedDial childrens size

      /// If true user is forced to close dial manually

      /// If false, backgroundOverlay will not be rendered.
      renderOverlay: true,
      // overlayColor: Colors.black,
      // overlayOpacity: 0.5,
      onOpen: () => debugPrint('OPENING DIAL'),
      onClose: () => debugPrint('DIAL CLOSED'),
      heroTag: 'speed-dial-hero-tag',
      // foregroundColor: Colors.black,
      // backgroundColor: Colors.white,
      // activeForegroundColor: Colors.red,
      // activeBackgroundColor: Colors.blue,
      elevation: 8.0,
      animationCurve: Curves.elasticInOut,
      isOpenOnStart: false,
      shape: const StadiumBorder(),
      // childMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      children: [
        SpeedDialChild(
            child: const Icon(Icons.poll),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: 'Create Event',
            onTap: () async {
              context.push(Uri(
                  path: '/createEvent',
                  queryParameters: {'groupId': groupId}).toString());
            }),
      ],
    );
  }
}
