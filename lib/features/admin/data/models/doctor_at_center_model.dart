import '../../domain/entities/doctor_at_center.dart';

class ScheduleBreakConfigModel extends ScheduleBreakConfig {
  const ScheduleBreakConfigModel({required super.startTime, required super.endTime});

  factory ScheduleBreakConfigModel.fromJson(Map<String, dynamic> j) =>
      ScheduleBreakConfigModel(
        startTime: j['startTime'] as String? ?? j['start_time'] as String? ?? '00:00',
        endTime: j['endTime'] as String? ?? j['end_time'] as String? ?? '00:00',
      );
}

class ScheduleExceptionModel extends ScheduleException {
  const ScheduleExceptionModel({
    super.id,
    required super.doctorId,
    required super.centerId,
    required super.date,
    required super.reason,
  });

  factory ScheduleExceptionModel.fromJson(Map<String, dynamic> j) {
    final rawDate = j['exceptionDate'] as String? ?? j['exception_date'] as String? ?? j['date'] as String? ?? '';
    return ScheduleExceptionModel(
      id: j['id'] as String?,
      doctorId: j['doctorId'] as String? ?? j['doctor_id'] as String? ?? '',
      centerId: j['centerId'] as String? ?? j['center_id'] as String? ?? '',
      date: DateTime.tryParse(rawDate) ?? DateTime.now(),
      reason: j['reason'] as String? ?? '',
    );
  }
}

// Parses a schedule from the backend response.
// Backend returns breakStart/breakEnd as top-level fields; old format may have
// a "breaks" array. We handle both.
List<ScheduleBreakConfig> _parseBreaks(Map<String, dynamic> j) {
  // New backend format: single breakStart / breakEnd fields
  final breakStart = j['breakStart'] as String? ?? j['break_start'] as String?;
  final breakEnd = j['breakEnd'] as String? ?? j['break_end'] as String?;
  if (breakStart != null && breakEnd != null) {
    return [ScheduleBreakConfigModel(startTime: breakStart, endTime: breakEnd)];
  }
  // Legacy list format
  final list = j['breaks'] as List?;
  if (list != null && list.isNotEmpty) {
    return list.map((e) => ScheduleBreakConfigModel.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

class DoctorScheduleConfigModel extends DoctorScheduleConfig {
  const DoctorScheduleConfigModel({
    super.id,
    required super.doctorId,
    required super.centerId,
    required super.workingDays,
    required super.startTime,
    required super.endTime,
    required super.slotDurationMinutes,
    super.breaks,
  });

  factory DoctorScheduleConfigModel.fromJson(Map<String, dynamic> j) =>
      DoctorScheduleConfigModel(
        id: j['id'] as String? ?? j['scheduleId'] as String?,
        doctorId: j['doctorId'] as String? ?? j['doctor_id'] as String? ?? '',
        centerId: j['centerId'] as String? ?? j['center_id'] as String? ?? '',
        // Accept both day-name strings (backend) and legacy int arrays
        workingDays: parseWorkingDays(j['workingDays'] ?? j['working_days']),
        startTime: j['startTime'] as String? ?? j['start_time'] as String? ?? '08:00',
        endTime: j['endTime'] as String? ?? j['end_time'] as String? ?? '17:00',
        slotDurationMinutes: j['slotDuration'] as int?
            ?? j['slotDurationMinutes'] as int?
            ?? j['slot_duration'] as int?
            ?? 30,
        breaks: _parseBreaks(j),
      );
}

class DoctorAtCenterModel extends DoctorAtCenter {
  const DoctorAtCenterModel({
    required super.doctorId,
    required super.fullName,
    super.specialization,
    required super.licenseNumber,
    super.licenseVerified,
    super.consultationFeeEtb,
    required super.joinedAt,
    super.status,
    super.todayAppointments,
    super.avatarUrl,
  });

  factory DoctorAtCenterModel.fromJson(Map<String, dynamic> j) => DoctorAtCenterModel(
        doctorId: j['doctorId'] as String? ?? j['doctor_id'] as String? ?? j['id'] as String? ?? '',
        fullName: j['fullName'] as String? ?? j['full_name'] as String? ?? j['name'] as String? ?? '',
        specialization: j['specialization'] as String?,
        licenseNumber: j['licenseNumber'] as String? ?? j['license_number'] as String? ?? '',
        licenseVerified: j['licenseVerified'] as bool? ?? j['license_verified'] as bool? ?? false,
        consultationFeeEtb: (j['consultationFee'] ?? j['consultation_fee'] as num?)?.toDouble() ?? 0,
        joinedAt: DateTime.tryParse(j['joinedAt'] as String? ?? j['joined_at'] as String? ?? '') ?? DateTime.now(),
        status: DoctorStatus.fromString(j['status'] as String?),
        todayAppointments: j['todayAppointments'] as int? ?? j['today_appointments'] as int? ?? 0,
        avatarUrl: j['avatarUrl'] as String? ?? j['avatar_url'] as String?,
      );
}
