import 'package:equatable/equatable.dart';

enum DayOfWeek {
  monday, tuesday, wednesday, thursday, friday, saturday, sunday;
  String get shortName => name.substring(0, 3).toUpperCase();
  static DayOfWeek fromInt(int d) => DayOfWeek.values[(d - 1).clamp(0, 6)];
}

class ScheduleBreak extends Equatable {
  final String label;
  final int startMinuteOfDay;
  final int durationMinutes;
  const ScheduleBreak({required this.label, required this.startMinuteOfDay, required this.durationMinutes});
  @override
  List<Object?> get props => [label, startMinuteOfDay, durationMinutes];
}

class DoctorSchedule extends Equatable {
  final String doctorId;
  final String centerId;
  final String centerName;
  final List<DayOfWeek> workingDays;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int slotDurationMinutes;
  final List<ScheduleBreak> breaks;

  const DoctorSchedule({
    required this.doctorId,
    required this.centerId,
    required this.centerName,
    required this.workingDays,
    required this.startHour,
    this.startMinute = 0,
    required this.endHour,
    this.endMinute = 0,
    required this.slotDurationMinutes,
    this.breaks = const [],
  });

  String get hoursLabel => '${_fmt(startHour, startMinute)} – ${_fmt(endHour, endMinute)}';
  String _fmt(int h, int m) => '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}';

  @override
  List<Object?> get props => [doctorId, centerId, centerName, workingDays, startHour, startMinute, endHour, endMinute, slotDurationMinutes, breaks];
}
