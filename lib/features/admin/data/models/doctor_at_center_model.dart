import '../../domain/entities/doctor_at_center.dart';

class ScheduleBreakConfigModel extends ScheduleBreakConfig {
  const ScheduleBreakConfigModel({required super.startTime, required super.endTime});

  factory ScheduleBreakConfigModel.fromJson(Map<String, dynamic> j) =>
      ScheduleBreakConfigModel(
        startTime: j['startTime'] as String? ?? j['start_time'] as String? ?? '00:00',
        endTime: j['endTime'] as String? ?? j['end_time'] as String? ?? '00:00',
      );
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
        id: j['id'] as String?,
        doctorId: j['doctorId'] as String? ?? j['doctor_id'] as String? ?? '',
        centerId: j['centerId'] as String? ?? j['center_id'] as String? ?? '',
        workingDays: (j['workingDays'] ?? j['working_days'] as List?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        startTime: j['startTime'] as String? ?? j['start_time'] as String? ?? '08:00',
        endTime: j['endTime'] as String? ?? j['end_time'] as String? ?? '17:00',
        slotDurationMinutes: j['slotDurationMinutes'] as int? ?? j['slot_duration_minutes'] as int? ?? 30,
        breaks: ((j['breaks']) as List?)
                ?.map((e) => ScheduleBreakConfigModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
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
