import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_event.dart';
import 'package:letshang/blocs/app_metadata/app_metadata_state.dart';

class AppMetadataBloc extends Bloc<AppMetadataEvent, AppMetadataState> {
  AppMetadataBloc() : super(const AppMetadataState());
  @override
  Stream<AppMetadataState> mapEventToState(AppMetadataEvent event) async* {
    if (event is AppPageIndexChanged) {
      yield state.copyWith(pageIndex: event.newPageIndex);
    }
  }
}
