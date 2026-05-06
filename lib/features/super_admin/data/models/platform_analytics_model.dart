import '../../domain/entities/platform_analytics.dart';

class PlatformAnalyticsModel extends PlatformAnalytics {
  const PlatformAnalyticsModel({
    super.totalRevenueEtb,
    super.revenueByCenterTop20,
    super.revenueByMonth,
    super.newCentersPerMonth,
    super.newDoctorsPerMonth,
    super.newPatientsPerMonth,
    super.churnRate30d,
    super.churnRate60d,
    super.churnRate90d,
  });

  factory PlatformAnalyticsModel.fromJson(Map<String, dynamic> j) {
    final revenueList = (j['revenueByCenterTop20'] as List? ?? []).map((e) {
      final m = e as Map<String, dynamic>;
      return RevenueByCenter(
        centerId: m['centerId'] as String? ?? '',
        centerName: m['centerName'] as String? ?? '',
        revenueEtb: (m['revenueEtb'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    return PlatformAnalyticsModel(
      totalRevenueEtb: (j['totalRevenueEtb'] as num?)?.toDouble() ?? 0,
      revenueByCenterTop20: revenueList,
      revenueByMonth: (j['revenueByMonth'] as Map?)
              ?.map((k, v) => MapEntry(k as String, (v as num).toDouble())) ??
          {},
      newCentersPerMonth: Map<String, int>.from(j['newCentersPerMonth'] as Map? ?? {}),
      newDoctorsPerMonth: Map<String, int>.from(j['newDoctorsPerMonth'] as Map? ?? {}),
      newPatientsPerMonth: Map<String, int>.from(j['newPatientsPerMonth'] as Map? ?? {}),
      churnRate30d: (j['churnRate30d'] as num?)?.toDouble() ?? 0,
      churnRate60d: (j['churnRate60d'] as num?)?.toDouble() ?? 0,
      churnRate90d: (j['churnRate90d'] as num?)?.toDouble() ?? 0,
    );
  }
}
