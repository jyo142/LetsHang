import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/app/app_state.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/repositories/user/user_repository.dart';
import 'package:letshang/services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final UserRepository _userRepository;

  AppBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const AppState());
  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is AppGoogleLoginRequested) {
      yield AppLoginLoading();
      try {
        User? user = await AuthenticationService.signInWithGoogle();
        if (user != null) {
          // first check if a user with the email already exists. if not create new user
          HangUser? curHangUser =
              await _userRepository.getUserByEmail(user.email!);

          if (curHangUser == null) {
            await _userRepository.addFirebaseUser(user.email!, user);
            yield AppNewFirebaseUser(firebaseUser: user);
          } else {
            if (curHangUser.userName.isEmpty) {
              yield AppNewFirebaseUser(firebaseUser: user);
            } else {
              yield* mapAuthenticatedUser(curHangUser);
            }
          }
        } else {
          yield const AppLoginError(
              errorMessage: "Failed to login with google");
        }
      } catch (e) {
        yield const AppLoginError(errorMessage: "Failed to login with google");
      }
    } else if (event is AppUserAuthReturned) {
      yield* mapAuthenticatedReturnedUser(event.userEmail);
    } else if (event is AppLoginRequested) {
      yield const AppIsLoggingIn();
    } else if (event is AppUserAuthenticated) {
      yield* mapAuthenticatedUser(event.hangUser);
    } else if (event is AppSignupRequested) {
      yield AppNewUser();
    } else {
      // user is logging out
      yield AppUnauthenticated();
    }
  }

  Stream<AppState> mapAuthenticatedReturnedUser(String userEmail) async* {
    final HangUser? foundUser = await _userRepository.getUserByEmail(userEmail);
    if (foundUser != null) {
      yield* mapAuthenticatedUser(foundUser);
    } else {
      yield AppReturnedUserError(errorMessage: "Unable to find user");
    }
  }

  Stream<AppState> mapAuthenticatedUser(HangUser curUser) async* {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    await _userRepository.updateFCMToken(curUser.email!, fcmToken);
    yield AppAuthenticated(user: curUser);
  }
}
