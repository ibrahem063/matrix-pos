import 'package:intl/intl.dart';

class DateHelper {
  static String dayId(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd  hh:mm a').format(date);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return startOfDay(date).add(const Duration(days: 1));
  }
}
