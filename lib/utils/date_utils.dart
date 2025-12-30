import 'package:intl/intl.dart';

class DateUtils {

  static String get todayApiFormat {
    return DateFormat('yyyyMMdd').format(DateTime.now());
  }


  static String formatForApi(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }


  static String formatMatchTime(String? apiTime) {
    if (apiTime == null || apiTime.isEmpty || apiTime == 'null') {
      return '--:--';
    }
    try {

      if (apiTime.length == 5 && apiTime.contains(':')) {
        return apiTime;
      }

      final parsed = DateTime.tryParse(apiTime);
      return parsed != null ? DateFormat('HH:mm').format(parsed) : apiTime;
    } catch (e) {
      return apiTime;
    }
  }


  static String formatDisplayDate(DateTime date) {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }


  static String formatMatchDate(String? apiDate) {
    if (apiDate == null || apiDate.isEmpty) return 'Date TBD';
    try {
      final year = apiDate.substring(0, 4);
      final month = apiDate.substring(4, 6);
      final day = apiDate.substring(6, 8);
      final date = DateTime.parse('$year-$month-$day');
      return DateFormat('EEE, MMM d').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }


  static String formatStatus(String? status) {
    if (status == null) return 'Scheduled';
    switch (status.toUpperCase()) {
      case 'LIVE':
      case 'INPLAY':
        return 'LIVE';
      case 'HT':
        return 'HT';
      case 'FT':
        return 'FT';
      case 'POSTPONED':
        return 'Postponed';
      default:
        return status;
    }
  }

  static String formatDateYYYYMMDDNoDash(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }


  static String formatDateReadable(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}