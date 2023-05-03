import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letshang/models/hang_user_model.dart';

abstract class AppMetadataEvent extends Equatable {}

class AppPageIndexChanged extends AppMetadataEvent {
  AppPageIndexChanged({required this.newPageIndex});

  final int newPageIndex;

  @override
  List<Object> get props => [newPageIndex];
}
