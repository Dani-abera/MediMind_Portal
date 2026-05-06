import '../../domain/entities/platform_subscription.dart';

class PlatformSubscriptionModel extends PlatformSubscription {
  const PlatformSubscriptionModel({
    super.centerId,
    super.centerName,
    super.plan,
    super.status,
    required super.startDate,
    required super.endDate,
    super.mrrEtb,
    super.lastPaymentAt,
    super.daysRemaining,
  });

  factory PlatformSubscriptionModel.fromJson(Map<String, dynamic> j) {
    final endDate = DateTime.tryParse(j['endDate'] as String? ?? '') ?? DateTime.now();
    final daysRemaining = endDate.difference(DateTime.now()).inDays.clamp(0, 9999);
    return PlatformSubscriptionModel(
      centerId: j['centerId'] as String? ?? '',
      centerName: j['centerName'] as String? ?? '',
      plan: j['plan'] as String? ?? 'trial',
      status: j['status'] as String? ?? 'active',
      startDate: DateTime.tryParse(j['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: endDate,
      mrrEtb: (j['mrrEtb'] as num?)?.toDouble() ?? 0,
      lastPaymentAt: j['lastPaymentAt'] != null
          ? DateTime.tryParse(j['lastPaymentAt'] as String)
          : null,
      daysRemaining: daysRemaining,
    );
  }

  Map<String, dynamic> toJson() => {
        'centerId': centerId,
        'centerName': centerName,
        'plan': plan,
        'status': status,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'mrrEtb': mrrEtb,
        'lastPaymentAt': lastPaymentAt?.toIso8601String(),
      };
}
