import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:letshang/blocs/event_responsibilities/hang_event_responsibilities_bloc.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/models/invite.dart';
import 'package:letshang/models/user_invite_model.dart';
import 'package:letshang/screens/events/event_details_add_responsibility.dart';

class EventDetailsFAB extends StatelessWidget {
  const EventDetailsFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HangEventOverviewBloc, HangEventOverviewState>(
      builder: (context, state) {
        if (state is IndividualEventLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is IndividualEventRetrieved) {
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
                  child: const Icon(Icons.brush),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  label: 'Add Responsibility',
                  onTap: () async {
                    final shouldRefresh = await context.push(
                        "/eventDetails/${state.hangEvent.id}/addEventResponsibility",
                        extra: state.hangEvent);
                    if (shouldRefresh as bool? ?? false) {
                      context.read<HangEventResponsibilitiesBloc>().add(
                          LoadEventResponsibilities(
                              eventId: state.hangEvent.id));
                      ;
                    }
                  }),
            ],
          );
        }
        return Text("error");
      },
    );
  }
}
