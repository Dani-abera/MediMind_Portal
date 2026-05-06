import 'package:equatable/equatable.dart';

class DayHours extends Equatable {
  final String day;
  final bool isClosed;
  final String? openTime;
  final String? closeTime;
  final String? breakStart;
  final String? breakEnd;

  const DayHours({
    required this.day,
    this.isClosed = false,
    this.openTime,
    this.closeTime,
    this.breakStart,
    this.breakEnd,
  });

  DayHours copyWith({
    String? day,
    bool? isClosed,
    String? openTime,
    String? closeTime,
    String? breakStart,
    String? breakEnd,
  }) =>
      DayHours(
        day: day ?? this.day,
        isClosed: isClosed ?? this.isClosed,
        openTime: openTime ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
        breakStart: breakStart ?? this.breakStart,
        breakEnd: breakEnd ?? this.breakEnd,
      );

  @override
  List<Object?> get props => [day, isClosed, openTime, closeTime, breakStart, breakEnd];
}

class WorkingHours extends Equatable {
  final List<DayHours> days;

  const WorkingHours({this.days = const []});

  WorkingHours copyWith({List<DayHours>? days}) =>
      WorkingHours(days: days ?? this.days);

  @override
  List<Object?> get props => [days];
}
