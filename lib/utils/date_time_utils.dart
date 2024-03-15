import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  static DateTime getCurrentDateTime(
      {required DateTime date, required TimeOfDay timeOfDay}) {
    return DateTime(
        date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
  }

  static bool isSameDay(DateTime firstDate, DateTime secondDate) {
    return firstDate.year == secondDate.year &&
        firstDate.month == secondDate.month &&
        firstDate.day == secondDate.day;
  }

  static int getMonthsPassed(DateTime startDate, DateTime endDate) {
    // Calculate the difference in years, months, and days
    int years = endDate.year - startDate.year;
    int months = endDate.month - startDate.month;
    int days = endDate.day - startDate.day;

    // Adjust for negative months or days
    if (days < 0) {
      months--;
      days += DateTime(endDate.year, endDate.month - 1, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    // Calculate the total number of months passed
    int totalMonthsPassed = years * 12 + months;
    return totalMonthsPassed;
  }

  static String getRelativeDateString(DateTime dateTime) {
    DateTime now = DateTime.now();
    if (isSameDay(now, dateTime)) {
      return DateFormat('hh:mm a').format(
        dateTime,
      );
    }
    Duration difference = now.difference(dateTime);
    bool isMoreThanAYearAgo = difference.inDays > 365;
    if (isMoreThanAYearAgo) {
      int yearsPassed = now.year - dateTime.year;
      if (yearsPassed == 1) {
        return "1 year ago";
      } else {
        return "$yearsPassed years ago";
      }
    }
    bool isMoreThanAMonthAgo = difference.inDays > 30;
    if (isMoreThanAMonthAgo) {
      int monthsPassed = getMonthsPassed(dateTime, now);
      if (monthsPassed == 1) {
        return "1 month ago";
      } else {
        return "$monthsPassed months ago";
      }
    }
    // less than a month difference
    int dayDifference = difference.inDays;
    if (dayDifference == 1) {
      return "1 day ago";
    }
    return "${difference.inDays} days ago";
  }

  static String changeTimeToString(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }
}
