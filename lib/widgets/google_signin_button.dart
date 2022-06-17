import 'package:flutter/material.dart';
import 'package:letshang/blocs/app/app_bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/screens/app_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/sign_up_screen.dart';
import 'package:letshang/services/message_service.dart';

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0), child: _signInButton());
  }

  Widget _signInButton() {
    return BlocConsumer<AppBloc, AppState>(
      builder: (context, state) {
        if (state is AppLoginLoading) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          );
        }
        if (state is AppLoginError) {
          MessageService.showErrorMessage(
              content: state.errorMessage!, context: context);
        }
        return OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            onPressed: () async {
              context.read<AppBloc>().add(AppLoginRequested());
            },
            child: _buttonContent());
      },
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
    );
  }

  Widget _buttonContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Image(
            image: AssetImage("assets/google_logo.png"),
            height: 35.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}
