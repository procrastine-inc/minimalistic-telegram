import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDate(int dateInSeconds, BuildContext context) {
  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(dateInSeconds * 1000);
  final timeFormat = MediaQuery.of(context).alwaysUse24HourFormat
      ? DateFormat.Hm() // 24-hour format (e.g., 14:30)
      : DateFormat.jm(); // 12-hour format (e.g., 2:30 PM)

  final last365Days = now.subtract(const Duration(days: 365));

  if (date.isAfter(last365Days) && date.isBefore(now)) {
    // Within the last 365 days, show month and day
    return DateFormat.MMMd()
        .format(date); // Month and day format (e.g., Jul 15)
  } else if (date.year == now.year) {
    if (date.month == now.month && date.day == now.day) {
      // Today, show time
      return timeFormat.format(date); // Format based on system settings
    } else if (date.isAfter(now.subtract(Duration(days: now.weekday - 1))) &&
        date.isBefore(
            now.add(Duration(days: DateTime.daysPerWeek - now.weekday)))) {
      // This week, show the day of the week
      return DateFormat.E().format(date); // Weekday format (e.g., Mon)
    } else {
      // Not within the last 365 days, show day.month.year
      return DateFormat.yMd()
          .format(date); // Full date format (e.g., 07/15/2022)
    }
  } else {
    // Not within the last 365 days and not this year, show day.month.year
    return DateFormat.yMd().format(date); // Full date format (e.g., 07/15/2022)
  }
}
