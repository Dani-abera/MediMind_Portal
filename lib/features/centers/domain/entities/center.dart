import 'package:equatable/equatable.dart';
import 'working_hours.dart';

class HealthcareCenter extends Equatable {
  final String centerId;
  final String centerName;
  final String centerType;
  final String licenseNumber;
  final String address;
  final String city;
  final String region;
  final String phoneNumber;
  final String email;
  final WorkingHours workingHours;
  final List<String> servicesOffered;
  final List<String> specializations;
  final String subscriptionStatus;
  final String? slotDurationMinutes;
  final String? advanceBookingDays;
  final String? cancellationHours;
  final bool autoApproveAppointments;
  final String? doctorCount;
  final String? distance;
  final bool isOpenNow;
  final String? warning;

  const HealthcareCenter({
    required this.centerId,
    required this.centerName,
    required this.centerType,
    required this.licenseNumber,
    required this.address,
    required this.city,
    required this.region,
    required this.phoneNumber,
    required this.email,
    required this.workingHours,
    required this.servicesOffered,
    required this.specializations,
    required this.subscriptionStatus,
    this.slotDurationMinutes,
    this.advanceBookingDays,
    this.cancellationHours,
    this.autoApproveAppointments = false,
    this.doctorCount,
    this.distance,
    this.isOpenNow = false,
    this.warning,
  });

  @override
  List<Object?> get props => [
        centerId,
        centerName,
        centerType,
        licenseNumber,
        address,
        city,
        region,
        phoneNumber,
        email,
        workingHours,
        servicesOffered,
        specializations,
        subscriptionStatus,
        slotDurationMinutes,
        advanceBookingDays,
        cancellationHours,
        autoApproveAppointments,
        doctorCount,
        distance,
        isOpenNow,
        warning,
      ];
}
