import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/app/app_event.dart';
import 'package:letshang/blocs/app/app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState());

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is AppUserLoggedIn) {
      yield AppState(status: AppStatus.authenticated, firebaseUser: event.user);
    } else {
      // user is logging out
      yield const AppState(
          status: AppStatus.unauthenticated, firebaseUser: null);
    }
  }
}
