import 'package:intl/intl.dart';

abstract class AppDateUtils {
  static String formatDate(DateTime dt) =>
      DateFormat('MMM d, yyyy').format(dt);

  static String formatDateTime(DateTime dt) =>
      DateFormat('MMM d, yyyy • h:mm a').format(dt);

  static String formatTime(DateTime dt) =>
      DateFormat('h:mm a').format(dt);

  static String formatShort(DateTime dt) =>
      DateFormat('MM/dd/yyyy').format(dt);

  static String relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
  }

  static String monthYear(DateTime dt) =>
      DateFormat('MMMM yyyy').format(dt);
}
