import '../../domain/entities/center.dart';
import 'working_hours_model.dart';

class CenterModel extends HealthcareCenter {
  const CenterModel({
    required super.centerId,
    required super.centerName,
    required super.centerType,
    required super.licenseNumber,
    required super.address,
    required super.city,
    required super.region,
    required super.phoneNumber,
    required super.email,
    required super.workingHours,
    required super.servicesOffered,
    required super.specializations,
    required super.subscriptionStatus,
    super.slotDurationMinutes,
    super.advanceBookingDays,
    super.cancellationHours,
    super.autoApproveAppointments,
    super.doctorCount,
    super.distance,
    super.isOpenNow,
    super.warning,
  });

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    return CenterModel(
      centerId: json['centerId'] as String? ?? '',
      centerName: json['centerName'] as String? ?? '',
      centerType: json['centerType'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      region: json['region'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      workingHours: WorkingHoursModel.fromJson(
        (json['workingHours'] as Map<String, dynamic>?) ?? {},
      ),
      servicesOffered: (json['servicesOffered'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      subscriptionStatus: json['subscriptionStatus'] as String? ?? '',
      slotDurationMinutes: json['slotDurationMinutes']?.toString(),
      advanceBookingDays: json['advanceBookingDays']?.toString(),
      cancellationHours: json['cancellationHours']?.toString(),
      autoApproveAppointments: json['autoApproveAppointments'] as bool? ?? false,
      doctorCount: json['doctorCount']?.toString(),
      distance: json['distance']?.toString(),
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      warning: json['warning'] as String?,
    );
  }
}
