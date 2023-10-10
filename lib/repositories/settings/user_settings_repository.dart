import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letshang/models/user_settings_model.dart';
import 'package:letshang/repositories/settings/base_user_settings_repository.dart';

class UserSettingsRepository extends BaseUserSettingsRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserSettingsRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<UserSettingsModel?> getUserSettings(String userId) async {
    DocumentSnapshot docSnapshot =
        await _firebaseFirestore.collection('userSettings').doc(userId).get();
    if (docSnapshot.exists) {
      return UserSettingsModel.fromSnapshot(docSnapshot);
    }
    return null;
  }

  @override
  Future<void> setUserSettings(
      String userId, UserSettingsModel userSettingsModel) {
    UserSettingsModel retVal = userSettingsModel;
    if (retVal.id?.isEmpty ?? true) {
      retVal = retVal.copyWith(
          id: FirebaseFirestore.instance.collection('userSettings').doc().id);
    }
    return _firebaseFirestore
        .collection('userSettings')
        .doc(userId)
        .set(userSettingsModel.toDocument());
  }
}
