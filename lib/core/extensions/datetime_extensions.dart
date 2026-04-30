import '../utils/date_utils.dart';

extension AppDateTimeExtensions on DateTime {
  String get formatted => AppDateUtils.formatDate(this);
  String get formattedDateTime => AppDateUtils.formatDateTime(this);
  String get formattedTime => AppDateUtils.formatTime(this);
  String get relative => AppDateUtils.relativeTime(this);
  bool get isToday => AppDateUtils.isToday(this);

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay =>
      DateTime(year, month, day, 23, 59, 59, 999);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
