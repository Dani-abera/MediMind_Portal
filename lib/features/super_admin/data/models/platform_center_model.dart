import '../../domain/entities/platform_center.dart';

class PlatformCenterModel extends PlatformCenter {
  const PlatformCenterModel({
    super.id,
    super.name,
    super.type,
    super.city,
    super.region,
    super.licenseNumber,
    super.licenseVerified,
    super.subscriptionStatus,
    super.doctorCount,
    super.patientCount,
    super.logoUrl,
    required super.createdAt,
    super.lastActivityAt,
    super.adminEmail,
    super.adminName,
    super.status,
    super.pendingPlanName,
    super.pendingPaymentRef,
    super.pendingPaymentStatus,
    super.pendingBillingCycle,
  });

  factory PlatformCenterModel.fromJson(Map<String, dynamic> j) => PlatformCenterModel(
        id: j['id'] as String? ?? '',
        name: j['centerName'] as String? ?? j['name'] as String? ?? '',
        type: j['centerType'] as String? ?? j['type'] as String? ?? '',
        city: j['city'] as String? ?? '',
        region: j['region'] as String? ?? '',
        licenseNumber: j['licenseNumber'] as String? ?? '',
        licenseVerified: j['licenseVerified'] as bool? ?? false,
        subscriptionStatus: j['subscriptionStatus'] as String? ?? 'trial',
        doctorCount: j['doctorCount'] as int? ?? 0,
        patientCount: j['patientCount'] as int? ?? 0,
        logoUrl: j['logoUrl'] as String?,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
        lastActivityAt: j['lastActivityAt'] != null
            ? DateTime.tryParse(j['lastActivityAt'] as String)
            : null,
        adminEmail: j['adminEmail'] as String? ?? j['email'] as String? ?? '',
        adminName: j['adminName'] as String? ?? '',
        status: _parseStatus(j['status'] as String? ?? j['subscriptionStatus'] as String?),
        pendingPlanName: j['pendingPlanName'] as String?,
        pendingPaymentRef: j['pendingPaymentRef'] as String?,
        pendingPaymentStatus: j['pendingPaymentStatus'] as String?,
        pendingBillingCycle: j['pendingBillingCycle'] as String?,
      );

  static CenterStatus _parseStatus(String? s) => switch (s?.toLowerCase()) {
        'active' => CenterStatus.active,
        'suspended' => CenterStatus.suspended,
        'rejected' => CenterStatus.rejected,
        'awaitingactivation' || 'awaiting_activation' => CenterStatus.awaitingActivation,
        'pendingapproval' || 'pending' => CenterStatus.pending,
        _ => CenterStatus.pending,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'city': city,
        'region': region,
        'licenseNumber': licenseNumber,
        'licenseVerified': licenseVerified,
        'subscriptionStatus': subscriptionStatus,
        'doctorCount': doctorCount,
        'patientCount': patientCount,
        'logoUrl': logoUrl,
        'createdAt': createdAt.toIso8601String(),
        'lastActivityAt': lastActivityAt?.toIso8601String(),
        'adminEmail': adminEmail,
        'adminName': adminName,
        'status': status.name,
        if (pendingPlanName != null) 'pendingPlanName': pendingPlanName,
        if (pendingPaymentRef != null) 'pendingPaymentRef': pendingPaymentRef,
        if (pendingPaymentStatus != null) 'pendingPaymentStatus': pendingPaymentStatus,
        if (pendingBillingCycle != null) 'pendingBillingCycle': pendingBillingCycle,
      };
}
