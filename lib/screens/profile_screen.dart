import 'package:flutter/material.dart';
import 'package:letshang/assets/MainTheme.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/blocs/profile/profile_bloc.dart';
import 'package:letshang/blocs/profile/profile_event.dart';
import 'package:letshang/blocs/profile/profile_state.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/screens/unauthorized_screen.dart';
import 'package:letshang/services/authentication_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/widgets/lh_button.dart';
import 'package:letshang/widgets/profile_pic.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const UnAuthorizedScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
      create: (context) => ProfileBloc(
          userRepository: UserRepository(),
          email: (context.read<AppBloc>().state).authenticatedUser!.email!)
        ..add(LoadProfile()),
      child: SafeArea(
          child: Stack(
        children: [
          _profileInformation(),
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF9BADBD),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      )),
    ));
  }

  Widget _profileInformation() {
    return BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
      if (state is ProfileInfoLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is ProfileInfoRetrieved) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfilePic(photoUrl: state.hangUser.photoUrl),
            const SizedBox(
              height: 15,
            ),
            Text(
              state.hangUser.name!,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '@${state.hangUser.userName}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .merge(const TextStyle(color: Color(0xFF04152D))),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
                child: IntrinsicHeight(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          state.userEventMetadata.numEventsOrganized.toString(),
                          style: Theme.of(context).textTheme.headline6!,
                        ),
                        Text(
                          'Events Organized',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .merge(const TextStyle(
                                fontWeight: FontWeight.w300,
                              )),
                        ),
                        const VerticalDivider(
                          color: Color(0xFFD7E1DC),
                          thickness: 2,
                        ),
                        Text(
                          state.userEventMetadata.numEvents.toString(),
                          style: Theme.of(context).textTheme.headline6!,
                        ),
                        Text(
                          'Events Attended',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .merge(const TextStyle(
                                fontWeight: FontWeight.w300,
                              )),
                        )
                      ]),
                )),
            const SizedBox(height: 8.0),
            const Text(
              'UserName',
              style: TextStyle(
                  color: Colors.grey, fontSize: 15, letterSpacing: .5),
            ),
            Text(state.hangUser.userName,
                style: Theme.of(context).textTheme.bodyText1),
            const SizedBox(height: 10.0),
            const Text(
              'Name',
              style: TextStyle(
                  color: Colors.grey, fontSize: 15, letterSpacing: .5),
            ),
            Text(state.hangUser.name!,
                style: Theme.of(context).textTheme.bodyText1),
            const SizedBox(height: 10.0),
            const Text('Email',
                style: TextStyle(
                    color: Colors.grey, fontSize: 15, letterSpacing: .5)),
            Text(
              state.hangUser.email!,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 10.0),
            const Text('Phone Number',
                style: TextStyle(
                    color: Colors.grey, fontSize: 15, letterSpacing: .5)),
            Text(
              state.hangUser.phoneNumber!,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 24.0),
            const SizedBox(height: 16.0),
            _logOutButton()
          ],
        );
      } else {
        return const Text(
          'You are not authenticated',
          style: TextStyle(color: Colors.grey, fontSize: 15, letterSpacing: .5),
        );
      }
    });
  }

  Widget _profilePicture(String? photoUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            photoUrl != null
                ? ClipOval(
                    child: Material(
                      color: Colors.grey,
                      child: Image.network(
                        photoUrl as String,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                : const ClipOval(
                    child: Material(
                      color: Colors.grey,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
          ],
        )
      ],
    );
  }

  Widget _logOutButton() {
    return _isLoggingOut
        ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
        : LHButton(
            buttonStyle: Theme.of(context).buttonTheme.errorButtonStyle,
            buttonText: 'Log Out',
            onPressed: () async {
              setState(() {
                _isLoggingOut = true;
              });
              await AuthenticationService.signOut(context: context);
              setState(() {
                _isLoggingOut = false;
              });
              context.read<AppBloc>().add(AppLogoutRequested());
              Navigator.of(context).pushReplacement(_routeToSignInScreen());
            },
          );
  }
}
