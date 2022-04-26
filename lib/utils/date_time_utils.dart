import 'package:flutter/material.dart';

class DateTimeUtils {
  static DateTime getCurrentDateTime(
      {required DateTime date, required TimeOfDay timeOfDay}) {
    return DateTime(
        date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
  }
}
