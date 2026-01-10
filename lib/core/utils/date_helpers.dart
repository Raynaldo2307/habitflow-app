class DateHelpers {
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String dateKey(DateTime date) {
    final normalized = startOfDay(date);
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String formatMediumDate(DateTime date) {
    final weekday = _weekdayShort[date.weekday - 1];
    final month = _monthShort[date.month - 1];
    return '$weekday, $month ${date.day}';
  }

  static String formatMonthDay(DateTime date) {
    final month = _monthShort[date.month - 1];
    return '$month ${date.day}';
  }

  static String weekdayShort(DateTime date) {
    return _weekdayShort[date.weekday - 1];
  }

  static List<DateTime> lastDays(DateTime end, int count) {
    final normalized = startOfDay(end);
    return List<DateTime>.generate(
      count,
      (index) => normalized.subtract(Duration(days: count - 1 - index)),
    );
  }

  static const List<String> _weekdayShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _monthShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}
