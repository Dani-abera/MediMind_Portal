import '../../domain/entities/subscription_history_entry.dart';

class SubscriptionHistoryEntryModel extends SubscriptionHistoryEntry {
  const SubscriptionHistoryEntryModel({
    required super.id,
    required super.oldStatus,
    required super.newStatus,
    super.plan,
    super.startDate,
    super.endDate,
    super.notes,
    required super.changedBy,
    required super.changedAt,
  });

  factory SubscriptionHistoryEntryModel.fromJson(Map<String, dynamic> j) {
    return SubscriptionHistoryEntryModel(
      id: j['id'] as String? ?? '',
      oldStatus: j['oldStatus'] as String? ?? '',
      newStatus: j['newStatus'] as String? ?? '',
      plan: j['plan'] as String?,
      startDate: j['startDate'] != null ? DateTime.tryParse(j['startDate'] as String) : null,
      endDate: j['endDate'] != null ? DateTime.tryParse(j['endDate'] as String) : null,
      notes: j['notes'] as String?,
      changedBy: j['changedBy'] as String? ?? '',
      changedAt: DateTime.tryParse(j['changedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class CenterSubscriptionDetailModel extends CenterSubscriptionDetail {
  const CenterSubscriptionDetailModel({
    required super.centerId,
    required super.centerName,
    required super.currentPlan,
    required super.subscriptionStatus,
    super.startDate,
    super.endDate,
    required super.isActive,
    required super.history,
  });

  factory CenterSubscriptionDetailModel.fromJson(Map<String, dynamic> j) {
    final historyList = (j['history'] as List? ?? [])
        .map((e) => SubscriptionHistoryEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return CenterSubscriptionDetailModel(
      centerId: j['centerId'] as String? ?? '',
      centerName: j['centerName'] as String? ?? '',
      currentPlan: j['currentPlan'] as String? ?? '',
      subscriptionStatus: j['subscriptionStatus'] as String? ?? '',
      startDate: j['startDate'] != null ? DateTime.tryParse(j['startDate'] as String) : null,
      endDate: j['endDate'] != null ? DateTime.tryParse(j['endDate'] as String) : null,
      isActive: j['isActive'] as bool? ?? false,
      history: historyList,
    );
  }
}
