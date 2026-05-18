import 'package:equatable/equatable.dart';

class SubscriptionHistoryEntry extends Equatable {
  final String id;
  final String oldStatus;
  final String newStatus;
  final String? plan;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;
  final String changedBy;
  final DateTime changedAt;

  const SubscriptionHistoryEntry({
    required this.id,
    required this.oldStatus,
    required this.newStatus,
    this.plan,
    this.startDate,
    this.endDate,
    this.notes,
    required this.changedBy,
    required this.changedAt,
  });

  @override
  List<Object?> get props =>
      [id, oldStatus, newStatus, plan, startDate, endDate, notes, changedBy, changedAt];
}

class CenterSubscriptionDetail extends Equatable {
  final String centerId;
  final String centerName;
  final String currentPlan;
  final String subscriptionStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<SubscriptionHistoryEntry> history;

  const CenterSubscriptionDetail({
    required this.centerId,
    required this.centerName,
    required this.currentPlan,
    required this.subscriptionStatus,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.history,
  });

  @override
  List<Object?> get props =>
      [centerId, centerName, currentPlan, subscriptionStatus, startDate, endDate, isActive, history];
}
