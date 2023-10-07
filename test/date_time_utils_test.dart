import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:letshang/utils/date_time_utils.dart';

void main() {
  test('Test formatting of current time', () {
    DateTime now = DateTime.now();
    String formatted = DateTimeUtils.getRelativeDateString(now);

    expect(formatted, DateFormat('hh:mm a').format(now));
  });

  test('Test formatting of a date more than a year ago', () {
    DateTime now = DateTime.now();
    DateTime olderDate =
        now.subtract(const Duration(days: 400)); // Adjust the date as needed
    String formatted = DateTimeUtils.getRelativeDateString(olderDate);

    expect(formatted, "1 year ago"); // Adjust the expected value as needed
  });

  test('Test formatting of a date more than 2 years ago', () {
    DateTime now = DateTime.now();
    DateTime olderDate =
        now.subtract(const Duration(days: 800)); // Adjust the date as needed
    String formatted = DateTimeUtils.getRelativeDateString(olderDate);

    expect(formatted, "2 years ago"); // Adjust the expected value as needed
  });
  test('Test formatting of a date more than a month ago', () {
    DateTime now = DateTime.now();
    DateTime olderDate =
        now.subtract(const Duration(days: 40)); // Adjust the date as needed
    String formatted = DateTimeUtils.getRelativeDateString(olderDate);

    expect(formatted, "1 month ago"); // Adjust the expected value as needed
  });

  test('Test formatting of a date more than a month ago multiple', () {
    DateTime now = DateTime.now();
    DateTime olderDate =
        now.subtract(const Duration(days: 70)); // Adjust the date as needed
    String formatted = DateTimeUtils.getRelativeDateString(olderDate);

    expect(formatted, "2 months ago"); // Adjust the expected value as needed
  });
  test('Test formatting of a date less than a month ago', () {
    DateTime now = DateTime.now();
    DateTime recentDate =
        now.subtract(const Duration(days: 2)); // Adjust the date as needed
    String formatted = DateTimeUtils.getRelativeDateString(recentDate);

    expect(formatted, "2 days ago"); // Adjust the expected value as needed
  });
}
