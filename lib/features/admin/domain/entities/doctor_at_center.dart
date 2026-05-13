import 'package:equatable/equatable.dart';

enum DoctorStatus {
  active,
  inactive;

  static DoctorStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'inactive' => inactive,
        _ => active,
      };
}

// ── Day helpers ───────────────────────────────────────────────────────────────

const _kDayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

String _dayIntToName(int day) => _kDayNames[(day - 1).clamp(0, 6)];

int _dayNameToInt(String name) {
  final idx = _kDayNames.indexWhere((d) => d.toLowerCase() == name.toLowerCase());
  return idx == -1 ? 1 : idx + 1;
}

List<int> parseWorkingDays(dynamic raw) {
  if (raw == null) return [];
  final list = raw as List;
  if (list.isEmpty) return [];
  if (list.first is int) return list.cast<int>();
  return list.cast<String>().map(_dayNameToInt).toList();
}

// ── Schedule entities ─────────────────────────────────────────────────────────

class ScheduleBreakConfig extends Equatable {
  final String startTime;
  final String endTime;

  const ScheduleBreakConfig({required this.startTime, required this.endTime});

  Map<String, dynamic> toJson() => {'startTime': startTime, 'endTime': endTime};

  @override
  List<Object?> get props => [startTime, endTime];
}

class DoctorScheduleConfig extends Equatable {
  final String? id;
  final String doctorId;
  final String centerId;
  final List<int> workingDays;
  final String startTime;
  final String endTime;
  final int slotDurationMinutes;
  final List<ScheduleBreakConfig> breaks;

  const DoctorScheduleConfig({
    this.id,
    required this.doctorId,
    required this.centerId,
    required this.workingDays,
    required this.startTime,
    required this.endTime,
    required this.slotDurationMinutes,
    this.breaks = const [],
  });

  DoctorScheduleConfig copyWith({
    String? id,
    String? doctorId,
    String? centerId,
    List<int>? workingDays,
    String? startTime,
    String? endTime,
    int? slotDurationMinutes,
    List<ScheduleBreakConfig>? breaks,
  }) =>
      DoctorScheduleConfig(
        id: id ?? this.id,
        doctorId: doctorId ?? this.doctorId,
        centerId: centerId ?? this.centerId,
        workingDays: workingDays ?? this.workingDays,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
        breaks: breaks ?? this.breaks,
      );

  // Backend expects:
  //   workingDays: ["Monday", "Tuesday", ...]
  //   slotDuration: int
  //   breakStart/breakEnd: single optional pair (only first break sent)
  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'centerId': centerId,
        'workingDays': workingDays.map(_dayIntToName).toList(),
        'startTime': startTime,
        'endTime': endTime,
        'slotDuration': slotDurationMinutes,
        if (breaks.isNotEmpty) 'breakStart': breaks.first.startTime,
        if (breaks.isNotEmpty) 'breakEnd': breaks.first.endTime,
      };

  @override
  List<Object?> get props => [id, doctorId, centerId, workingDays, startTime, endTime, slotDurationMinutes, breaks];
}

// ── Schedule Exception (out-of-office date) ───────────────────────────────────

class ScheduleException extends Equatable {
  final String? id;
  final String doctorId;
  final String centerId;
  final DateTime date;
  final String reason;

  const ScheduleException({
    this.id,
    required this.doctorId,
    required this.centerId,
    required this.date,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'reason': reason,
      };

  @override
  List<Object?> get props => [id, doctorId, centerId, date, reason];
}

// ── Doctor at center ──────────────────────────────────────────────────────────

class DoctorAtCenter extends Equatable {
  final String doctorId;
  final String fullName;
  final String? specialization;
  final String licenseNumber;
  final bool licenseVerified;
  final double consultationFeeEtb;
  final DateTime joinedAt;
  final DoctorStatus status;
  final int todayAppointments;
  final String? avatarUrl;

  const DoctorAtCenter({
    required this.doctorId,
    required this.fullName,
    this.specialization,
    required this.licenseNumber,
    this.licenseVerified = false,
    this.consultationFeeEtb = 0,
    required this.joinedAt,
    this.status = DoctorStatus.active,
    this.todayAppointments = 0,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        doctorId, fullName, specialization, licenseNumber, licenseVerified,
        consultationFeeEtb, joinedAt, status, todayAppointments, avatarUrl,
      ];
}

// ── Invite doctor DTO ─────────────────────────────────────────────────────────

class InviteDoctorDto extends Equatable {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String specialization;
  final String licenseNumber;
  final int yearsOfExperience;
  final double consultationFee;

  const InviteDoctorDto({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.specialization,
    required this.licenseNumber,
    required this.yearsOfExperience,
    required this.consultationFee,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'specialization': specialization,
        'licenseNumber': licenseNumber,
        'yearsOfExperience': yearsOfExperience,
        'consultationFee': consultationFee,
      };

  @override
  List<Object?> get props => [fullName, email, phoneNumber, specialization, licenseNumber, yearsOfExperience, consultationFee];
}
