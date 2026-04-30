import '../utils/formatters.dart';

extension AppNumExtensions on num {
  String get formatted => AppFormatters.number(this);
  String get asCurrency => AppFormatters.currency(toDouble());
  String get asPercent => AppFormatters.percentage(toDouble());

  bool between(num min, num max) => this >= min && this <= max;
}
