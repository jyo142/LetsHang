import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:letshang/blocs/profile/profile_event.dart';
import 'package:letshang/blocs/profile/profile_state.dart';
import 'package:letshang/models/hang_user_model.dart';
import 'package:letshang/models/user_event_metadata.dart';
import 'package:letshang/repositories/invites/base_invites_repository.dart';
import 'package:letshang/repositories/invites/invites_repository.dart';
import 'package:letshang/repositories/user/user_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final BaseUserInvitesRepository _userInvitesRepository;
  final String email;

  ProfileBloc({required UserRepository userRepository, required this.email})
      : _userRepository = userRepository,
        _userInvitesRepository = UserInvitesRepository(),
        super(ProfileInfoLoading(email: email)) {
    on<LoadProfile>((event, emit) async {
      emit(await _mapLoadProfileToState());
    });
  }

  Future<ProfileState> _mapLoadProfileToState() async {
    try {
      HangUser? hangUser = await _userRepository.getUserByEmail(email);
      // get metadata for events about user
      UserEventMetadata userEventMetadata =
          await _userInvitesRepository.getUserEventMetadata(email);
      // user has to be in the system at this point
      return ProfileInfoRetrieved(
          hangUser: hangUser!, userEventMetadata: userEventMetadata);
    } catch (e) {
      return ProfileInfoError(
          errorMessage: "Unable to retrieve profile information.");
    }
  }
}
