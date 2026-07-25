import 'package:intl/intl.dart';

/// App-wide date/time display formatting — day-month-year order and
/// 12-hour clock everywhere, regardless of device locale (unlike
/// `DateFormat.yMMMd()`/`.jm()`, whose order and 12h/24h choice both follow
/// the device's locale). Display only: wire/storage formats (ISO 8601,
/// `yyyy-MM-dd` API fields) are a separate concern and must not use this.
abstract final class AppDateFormat {
  static final _date = DateFormat('d MMM y');
  static final _dateWithWeekday = DateFormat('EEE, d MMM y');
  static final _time = DateFormat('h:mm a');
  static final _shortAxisDate = DateFormat('d MMM');

  /// e.g. "25 Jul 2026"
  static String date(DateTime dt) => _date.format(dt);

  /// e.g. "Sat, 25 Jul 2026"
  static String dateWithWeekday(DateTime dt) => _dateWithWeekday.format(dt);

  /// e.g. "3:45 PM"
  static String time(DateTime dt) => _time.format(dt);

  /// e.g. "25 Jul 2026, 3:45 PM"
  static String dateTime(DateTime dt) => '${date(dt)}, ${time(dt)}';

  /// e.g. "Sat, 25 Jul 2026, 3:45 PM"
  static String dateTimeWithWeekday(DateTime dt) =>
      '${dateWithWeekday(dt)}, ${time(dt)}';

  /// Short form for space-constrained chart axis labels, e.g. "25 Jul".
  static String shortAxisDate(DateTime dt) => _shortAxisDate.format(dt);
}
