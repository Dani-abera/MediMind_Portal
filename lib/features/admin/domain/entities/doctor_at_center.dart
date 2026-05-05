import 'package:equatable/equatable.dart';

enum DoctorStatus {
  active,
  inactive;

  static DoctorStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'inactive' => inactive,
        _ => active,
      };
}

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

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'doctorId': doctorId,
        'centerId': centerId,
        'workingDays': workingDays,
        'startTime': startTime,
        'endTime': endTime,
        'slotDurationMinutes': slotDurationMinutes,
        'breaks': breaks.map((b) => b.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, doctorId, centerId, workingDays, startTime, endTime, slotDurationMinutes, breaks];
}

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
