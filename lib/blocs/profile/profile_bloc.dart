import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/profile/profile_event.dart';
import 'package:letshang/blocs/profile/profile_state.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/repositories/user/user_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final String userName;

  ProfileBloc({required UserRepository userRepository, required this.userName})
      : _userRepository = userRepository,
        super(ProfileInfoLoading(userName: userName));
  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is LoadProfile) {
      yield* _mapLoadProfileToState();
    }
  }

  Stream<ProfileState> _mapLoadProfileToState() async* {
    try {
      HangUser? hangUser = await _userRepository.getUserByUserName(userName);
      // user has to be in the system at this point
      yield ProfileInfoRetrieved(hangUser: hangUser!);
    } catch (e) {
      yield ProfileInfoError(
          errorMessage: "Unable to retrieve profile information.");
    }
  }
}
