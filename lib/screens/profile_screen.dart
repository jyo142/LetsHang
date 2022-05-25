import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/screens/sign_in_screen.dart';
import 'package:letshang/services/authentication_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          const SignInScreen(),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
        child: _profileInformation(),
      ),
    );
  }

  Widget _profileInformation() {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      if (state is AppAuthenticated) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profilePicture(state.user.photoUrl),
            const SizedBox(height: 8.0),
            const Text(
              'Name',
              style: TextStyle(
                  color: Colors.grey, fontSize: 15, letterSpacing: .5),
            ),
            Text('${state.user.name!}',
                style: const TextStyle(fontSize: 15, letterSpacing: .5)),
            const SizedBox(height: 10.0),
            const Text('Email',
                style: TextStyle(
                    color: Colors.grey, fontSize: 15, letterSpacing: .5)),
            Text(
              state.user.email! as String,
              style: const TextStyle(
                fontSize: 15,
                letterSpacing: 0.5,
              ),
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
        : ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.redAccent,
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
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
            child: const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          );
  }
}
