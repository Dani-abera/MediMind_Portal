import '../../domain/entities/doctor_schedule.dart';

class ScheduleBreakModel extends ScheduleBreak {
  const ScheduleBreakModel({
    required super.label,
    required super.startMinuteOfDay,
    required super.durationMinutes,
  });

  factory ScheduleBreakModel.fromJson(Map<String, dynamic> json) => ScheduleBreakModel(
        label: json['label'] as String,
        startMinuteOfDay: json['startMinuteOfDay'] as int,
        durationMinutes: json['durationMinutes'] as int,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'startMinuteOfDay': startMinuteOfDay,
        'durationMinutes': durationMinutes,
      };
}

class DoctorScheduleModel extends DoctorSchedule {
  const DoctorScheduleModel({
    required super.doctorId,
    required super.centerId,
    required super.centerName,
    required super.workingDays,
    required super.startHour,
    super.startMinute,
    required super.endHour,
    super.endMinute,
    required super.slotDurationMinutes,
    super.breaks,
  });

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    final workingDays = (json['workingDays'] as List<dynamic>? ?? []).map((e) {
      if (e is int) return DayOfWeek.fromInt(e);
      return DayOfWeek.values.byName(e as String);
    }).toList();

    return DoctorScheduleModel(
      doctorId: json['doctorId'] as String,
      centerId: json['centerId'] as String,
      centerName: json['centerName'] as String,
      workingDays: workingDays,
      startHour: json['startHour'] as int,
      startMinute: json['startMinute'] as int? ?? 0,
      endHour: json['endHour'] as int,
      endMinute: json['endMinute'] as int? ?? 0,
      slotDurationMinutes: json['slotDurationMinutes'] as int,
      breaks: (json['breaks'] as List<dynamic>? ?? [])
          .map((e) => ScheduleBreakModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'centerId': centerId,
        'centerName': centerName,
        'workingDays': workingDays.map((d) => d.name).toList(),
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
        'slotDurationMinutes': slotDurationMinutes,
        'breaks': breaks
            .map((b) => ScheduleBreakModel(
                  label: b.label,
                  startMinuteOfDay: b.startMinuteOfDay,
                  durationMinutes: b.durationMinutes,
                ).toJson())
            .toList(),
      };
}
