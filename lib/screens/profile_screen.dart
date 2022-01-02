import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/screens/sign_in_screen.dart';
import 'package:letshang/utils/authentication.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSigningOut = false;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
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
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.blue,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.blue,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(),
                  state.firebaseUser?.photoURL != null
                      ? ClipOval(
                          child: Material(
                            color: Colors.grey,
                            child: Image.network(
                              state.firebaseUser?.photoURL! as String,
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
                  const SizedBox(height: 16.0),
                  const Text(
                    'Hello',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    state.firebaseUser?.displayName! as String,
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '( ${state.firebaseUser?.email!} )',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  const Text(
                    'You are now signed in using your Google account. To sign out of your account, click the "Sign Out" button below.',
                    style: TextStyle(
                        color: Colors.grey, fontSize: 14, letterSpacing: 0.2),
                  ),
                  const SizedBox(height: 16.0),
                  _signOutButton()
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _signOutButton() {
    return _isSigningOut
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
                _isSigningOut = true;
              });
              await Authentication.signOut(context: context);
              setState(() {
                _isSigningOut = false;
              });
              Navigator.of(context).pushReplacement(_routeToSignInScreen());
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                'Sign Out',
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
