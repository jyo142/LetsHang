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
        super(const AppState(appStateStatus: AppStateStatus.initial)) {
    on<AppGoogleLoginRequested>((event, emit) async {
      emit(state.copyWith(appStateStatus: AppStateStatus.loginLoading));
      try {
        User? user = await AuthenticationService.signInWithGoogle();
        if (user != null) {
          // first check if a user with the email already exists. if not create new user
          HangUser? curHangUser =
              await _userRepository.getUserByEmail(user.email!);

          if (curHangUser == null) {
            await _userRepository.addFirebaseUser(user.email!, user);
            emit(state.copyWith(
                appStateStatus: AppStateStatus.newFirebaseUser,
                firebaseUser: user));
          } else {
            if (curHangUser.userName.isEmpty) {
              emit(state.copyWith(
                  appStateStatus: AppStateStatus.newFirebaseUser,
                  firebaseUser: user));
            } else {
              emit(await mapAuthenticatedUser(curHangUser));
            }
          }
        } else {
          emit(state.copyWith(
              appStateStatus: AppStateStatus.loginError,
              errorMessage: "Failed to login with google"));
        }
      } catch (e) {
        emit(state.copyWith(
            appStateStatus: AppStateStatus.loginError,
            errorMessage: "Failed to login with google"));
      }
    });
    on<AppUserAuthReturned>((event, emit) async {
      emit(await mapAuthenticatedReturnedUser(event.userEmail));
    });
    on<AppLoginRequested>((event, emit) async {
      emit(state.copyWith(appStateStatus: AppStateStatus.isLoggingIn));
    });
    on<AppUserAuthenticated>((event, emit) async {
      emit(await mapAuthenticatedUser(event.hangUser));
    });
    on<AppSignupRequested>((event, emit) async {
      emit(state.copyWith(appStateStatus: AppStateStatus.newUser));
    });
    on<AppLogoutRequested>((event, emit) async {
      emit(state.copyWith(appStateStatus: AppStateStatus.unauthenticated));
    });
  }

  Future<AppState> mapAuthenticatedReturnedUser(String userEmail) async {
    final HangUser? foundUser = await _userRepository.getUserByEmail(userEmail);
    if (foundUser != null) {
      return mapAuthenticatedUser(foundUser);
    } else {
      return state.copyWith(
          appStateStatus: AppStateStatus.loginError,
          errorMessage: "Unable to find user");
    }
  }

  Future<AppState> mapAuthenticatedUser(HangUser curUser) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    await _userRepository.updateFCMToken(curUser.id!, fcmToken);
    return state.copyWith(
        appStateStatus: AppStateStatus.authenticated,
        authenticatedUser: curUser);
  }
}
