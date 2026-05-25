import 'package:equatable/equatable.dart';

enum CenterStatus { pending, active, suspended, rejected, awaitingActivation }

class PlatformCenter extends Equatable {
  final String id;
  final String name;
  final String type;
  final String city;
  final String region;
  final String licenseNumber;
  final bool licenseVerified;
  final String subscriptionStatus;
  final int doctorCount;
  final int patientCount;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final String adminEmail;
  final String adminName;
  final CenterStatus status;
  final String? pendingPlanName;
  final String? pendingPaymentRef;
  final String? pendingPaymentStatus;
  final String? pendingBillingCycle;

  const PlatformCenter({
    this.id = '',
    this.name = '',
    this.type = '',
    this.city = '',
    this.region = '',
    this.licenseNumber = '',
    this.licenseVerified = false,
    this.subscriptionStatus = 'trial',
    this.doctorCount = 0,
    this.patientCount = 0,
    this.logoUrl,
    required this.createdAt,
    this.lastActivityAt,
    this.adminEmail = '',
    this.adminName = '',
    this.status = CenterStatus.pending,
    this.pendingPlanName,
    this.pendingPaymentRef,
    this.pendingPaymentStatus,
    this.pendingBillingCycle,
  });

  @override
  List<Object?> get props => [
        id, name, type, city, region, licenseNumber, licenseVerified,
        subscriptionStatus, doctorCount, patientCount, logoUrl, createdAt,
        lastActivityAt, adminEmail, adminName, status,
        pendingPlanName, pendingPaymentRef, pendingPaymentStatus, pendingBillingCycle,
      ];
}
