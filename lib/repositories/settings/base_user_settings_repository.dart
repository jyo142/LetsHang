import 'package:letshang/models/notifications_model.dart';
import 'package:letshang/models/user_settings_model.dart';

abstract class BaseUserSettingsRepository {
  Future<UserSettingsModel?> getUserSettings(String userId);
  Future<void> setUserSettings(
      String userId, UserSettingsModel userSettingsModel);
}
