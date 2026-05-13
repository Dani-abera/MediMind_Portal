import '../../domain/entities/subscription_plan.dart';

class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.tier,
    required super.monthlyPrice,
    required super.yearlyPrice,
    required super.maxDoctors,
    required super.maxAppointmentsPerDay,
    required super.features,
    super.description,
    super.isActive,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> j) {
    return SubscriptionPlanModel(
      id: j['planId'] as String? ?? j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      tier: (j['tier'] ?? '').toString(),
      monthlyPrice: (j['monthlyPrice'] as num? ?? 0).toDouble(),
      yearlyPrice: (j['yearlyPrice'] as num? ?? 0).toDouble(),
      maxDoctors: j['maxDoctors'] as int? ?? 0,
      maxAppointmentsPerDay: j['maxAppointmentsPerDay'] as int? ?? 0,
      features: (j['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      description: j['description'] as String?,
      isActive: j['isActive'] as bool? ?? true,
    );
  }
}
