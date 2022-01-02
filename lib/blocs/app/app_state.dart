import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
}

class AppState extends Equatable {
  const AppState({this.status = AppStatus.unauthenticated, this.firebaseUser});

  final AppStatus status;
  final User? firebaseUser;

  @override
  List<Object?> get props => [status, firebaseUser];
}
