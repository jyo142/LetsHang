import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:letshang/screens/login_screen.dart';
import 'package:letshang/screens/sign_up_screen.dart';
import 'package:letshang/widgets/google_signin_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnAuthorizedScreen extends StatelessWidget {
  const UnAuthorizedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(height: 20),
                    Text(
                      'Let\'s Hang',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
              ),
              _authButtons()
            ],
          ),
        ),
      ),
    );
  }

  Widget _authButtons() {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const AppScreen(),
            ),
          );
        }
        if (state is AppNewUser) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SignUpScreen(
                firebaseUser: state.firebaseUser,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _loginButton(context),
            const GoogleSignInButton(),
            _createAccountButton(context)
          ],
        );
      },
    );
  }

  Widget _loginButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: OutlinedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          onPressed: () async {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          )),
    );
  }

  Widget _createAccountButton(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SignUpScreen(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            )));
  }
}
