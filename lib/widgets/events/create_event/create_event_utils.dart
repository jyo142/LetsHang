import 'package:letshang/models/events/hang_event_recurring_settings.dart';

class CreateEventUtils {
  static String? getRecurringIntervalName(
      HangEventRecurringType recurringType) {
    switch (recurringType) {
      case HangEventRecurringType.daily:
        return "Days";
      case HangEventRecurringType.monthly:
        return "Months";
      case HangEventRecurringType.weekly:
        return "Weeks";
      case HangEventRecurringType.yearly:
        return "Years";
      default:
        return null;
    }
  }
}
