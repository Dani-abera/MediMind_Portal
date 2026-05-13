import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String tier;
  final double monthlyPrice;
  final double yearlyPrice;
  final int maxDoctors;
  final int maxAppointmentsPerDay;
  final List<String> features;
  final String? description;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.maxDoctors,
    required this.maxAppointmentsPerDay,
    required this.features,
    this.description,
    this.isActive = true,
  });

  bool get isFree => monthlyPrice == 0;

  @override
  List<Object?> get props => [
        id, name, tier, monthlyPrice, yearlyPrice,
        maxDoctors, maxAppointmentsPerDay, features, description, isActive,
      ];
}
