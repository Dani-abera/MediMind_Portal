import '../../domain/entities/platform_dashboard_data.dart';

class PlatformDashboardModel extends PlatformDashboardData {
  const PlatformDashboardModel({
    super.totalCenters,
    super.activeCenters,
    super.totalDoctors,
    super.verifiedDoctors,
    super.totalPatients,
    super.mau,
    super.monthlyRevenueEtb,
    super.openTickets,
    super.pendingApprovals,
    super.pendingLicenses,
    super.platformGrowth,
    super.topCentersByRevenue,
    super.subscriptionBreakdown,
  });

  factory PlatformDashboardModel.fromJson(Map<String, dynamic> j) {
    final growthList = (j['platformGrowth'] as List? ?? []).map((e) {
      final m = e as Map<String, dynamic>;
      return ChartPoint(
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
        centers: m['centers'] as int? ?? 0,
        doctors: m['doctors'] as int? ?? 0,
        patients: m['patients'] as int? ?? 0,
      );
    }).toList();

    final revenueList = (j['topCentersByRevenue'] as List? ?? []).map((e) {
      final m = e as Map<String, dynamic>;
      return CenterRevenue(
        centerId: m['centerId'] as String? ?? '',
        centerName: m['centerName'] as String? ?? '',
        revenueEtb: (m['revenueEtb'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    return PlatformDashboardModel(
      totalCenters: j['totalCenters'] as int? ?? 0,
      activeCenters: j['activeCenters'] as int? ?? 0,
      totalDoctors: j['totalDoctors'] as int? ?? 0,
      verifiedDoctors: j['verifiedDoctors'] as int? ?? 0,
      totalPatients: j['totalPatients'] as int? ?? 0,
      mau: j['mau'] as int? ?? 0,
      monthlyRevenueEtb: (j['monthlyRevenueEtb'] as num?)?.toDouble() ?? 0,
      openTickets: j['openTickets'] as int? ?? 0,
      pendingApprovals: j['pendingApprovals'] as int? ?? 0,
      pendingLicenses: j['pendingLicenses'] as int? ?? 0,
      platformGrowth: growthList,
      topCentersByRevenue: revenueList,
      subscriptionBreakdown: Map<String, int>.from(j['subscriptionBreakdown'] as Map? ?? {}),
    );
  }
}
