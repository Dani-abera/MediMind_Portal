import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/revenue_data.dart';

class TimeSeriesPointModel extends TimeSeriesPoint {
  const TimeSeriesPointModel({required super.date, required super.value, super.series});

  factory TimeSeriesPointModel.fromJson(Map<String, dynamic> j, {String? series}) =>
      TimeSeriesPointModel(
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        value: (j['value'] as num?)?.toDouble() ?? 0,
        series: series ?? j['series'] as String?,
      );
}

class HeatmapCellModel extends HeatmapCell {
  const HeatmapCellModel({required super.dayOfWeek, required super.hour, required super.value});

  factory HeatmapCellModel.fromJson(Map<String, dynamic> j) => HeatmapCellModel(
        dayOfWeek: j['dayOfWeek'] as int? ?? j['day_of_week'] as int? ?? 0,
        hour: j['hour'] as int? ?? 0,
        // API sends 'count'; fall back to 'value' for older shapes
        value: j['count'] as int? ?? j['value'] as int? ?? 0,
      );
}

class DoctorAnalyticsStatModel extends DoctorAnalyticsStat {
  const DoctorAnalyticsStatModel({
    required super.doctorId,
    required super.doctorName,
    required super.noShowRate,
    required super.utilizationPercent,
    required super.revenueEtb,
    required super.avgWaitMinutes,
  });

  factory DoctorAnalyticsStatModel.fromJson(Map<String, dynamic> j) => DoctorAnalyticsStatModel(
        doctorId: j['doctorId'] as String? ?? j['doctor_id'] as String? ?? '',
        doctorName: j['doctorName'] as String? ?? j['doctor_name'] as String? ?? '',
        noShowRate: (j['noShowRate'] ?? j['no_show_rate'] as num?)?.toDouble() ?? 0,
        utilizationPercent: (j['utilizationPercent'] ?? j['utilization_percent'] as num?)?.toDouble() ?? 0,
        revenueEtb: (j['revenueEtb'] ?? j['revenue_etb'] as num?)?.toDouble() ?? 0,
        avgWaitMinutes: (j['avgWaitMinutes'] ?? j['avg_wait_minutes'] as num?)?.toDouble() ?? 0,
      );
}

class AnalyticsSummaryModel extends AnalyticsSummary {
  const AnalyticsSummaryModel({
    super.totalAppointments,
    super.completedAppointments,
    super.cancelledAppointments,
    super.noShowCount,
    super.noShowRate,
    super.totalRevenueEtb,
    super.newPatients,
    super.doctorUtilizationPercent,
    super.prevTotalAppointments,
    super.prevTotalRevenueEtb,
    super.prevNewPatients,
    super.prevDoctorUtilizationPercent,
    super.completedTrend,
    super.cancelledTrend,
    super.noShowTrend,
    super.statusDistribution,
    super.peakHours,
    super.doctorStats,
    super.avgWaitTimeTrend,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> j) {
    // API shape: summary stats nested under 'summary', revenue under 'revenueMetrics'
    final summary = j['summary'] as Map<String, dynamic>? ?? j;
    final revenue = j['revenueMetrics'] as Map<String, dynamic>? ?? {};

    List<TimeSeriesPoint> series(String key) =>
        ((j[key]) as List?)
            ?.map((e) => TimeSeriesPointModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Merge noShowRateByDoctor + doctorUtilization into DoctorAnalyticsStat list
    final noShowMap = <String, Map<String, dynamic>>{};
    for (final e in (j['noShowRateByDoctor'] as List? ?? [])) {
      final m = e as Map<String, dynamic>;
      noShowMap[m['doctorId'] as String? ?? ''] = m;
    }
    final doctorStats = (j['doctorUtilization'] as List? ?? []).map((e) {
      final u = e as Map<String, dynamic>;
      final id = u['doctorId'] as String? ?? '';
      final ns = noShowMap[id] ?? {};
      return DoctorAnalyticsStatModel(
        doctorId: id,
        doctorName: u['doctorName'] as String? ?? '',
        noShowRate: (ns['noShowRate'] as num?)?.toDouble() ?? 0,
        utilizationPercent: (u['utilizationPercent'] as num?)?.toDouble() ?? 0,
        revenueEtb: 0,
        avgWaitMinutes: (j['averageWaitTimeMinutes'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    final totalAppointments =
        summary['totalAppointments'] as int? ?? 0;
    final completedCount = summary['completedCount'] as int? ?? 0;
    final cancelledCount = summary['cancelledCount'] as int? ?? 0;
    final noShowCount = summary['noShowCount'] as int? ?? 0;
    final noShowRate = totalAppointments > 0
        ? noShowCount / totalAppointments
        : 0.0;

    return AnalyticsSummaryModel(
      totalAppointments: totalAppointments,
      completedAppointments: completedCount,
      cancelledAppointments: cancelledCount,
      noShowCount: noShowCount,
      noShowRate: noShowRate,
      totalRevenueEtb: (revenue['totalRevenue'] as num?)?.toDouble() ??
          (j['totalRevenueEtb'] as num?)?.toDouble() ??
          0,
      newPatients: summary['newPatientsCount'] as int? ??
          summary['newPatients'] as int? ??
          0,
      doctorUtilizationPercent: doctorStats.isEmpty
          ? 0
          : doctorStats
                  .map((d) => d.utilizationPercent)
                  .reduce((a, b) => a + b) /
              doctorStats.length,
      prevTotalAppointments: j['prevTotalAppointments'] as int?,
      prevTotalRevenueEtb: (j['prevTotalRevenueEtb'] as num?)?.toDouble(),
      prevNewPatients: j['prevNewPatients'] as int?,
      prevDoctorUtilizationPercent:
          (j['prevDoctorUtilizationPercent'] as num?)?.toDouble(),
      completedTrend: series('completedTrend'),
      cancelledTrend: series('cancelledTrend'),
      noShowTrend: series('noShowTrend'),
      statusDistribution: {
        'completed': completedCount,
        'cancelled': cancelledCount,
        'noShow': noShowCount,
        'pending': totalAppointments - completedCount - cancelledCount - noShowCount,
      },
      peakHours: ((j['peakHoursHeatmap'] ?? j['peakHours'] ?? j['peak_hours']) as List?)
              ?.map((e) => HeatmapCellModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      doctorStats: doctorStats,
      avgWaitTimeTrend: series('avgWaitTimeTrend'),
    );
  }
}

class RevenueRowModel extends RevenueRow {
  const RevenueRowModel({
    required super.date,
    required super.appointmentId,
    required super.doctorName,
    required super.patientMasked,
    required super.amount,
    required super.method,
    required super.status,
  });

  factory RevenueRowModel.fromJson(Map<String, dynamic> j) => RevenueRowModel(
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        appointmentId: j['appointmentId'] as String? ?? j['appointment_id'] as String? ?? '',
        doctorName: j['doctorName'] as String? ?? j['doctor_name'] as String? ?? '',
        patientMasked: j['patientMasked'] as String? ?? j['patient_masked'] as String? ?? '***',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        method: j['method'] as String? ?? '',
        status: j['status'] as String? ?? '',
      );
}

class RevenueSummaryModel extends RevenueSummary {
  const RevenueSummaryModel({
    super.totalRevenue,
    super.pendingPayments,
    super.refunded,
    super.avgPerAppointment,
    super.prevTotalRevenue,
    super.trend,
    super.rows,
    super.totalRows,
  });

  factory RevenueSummaryModel.fromJson(Map<String, dynamic> j) {
    // "groups" is the time-series breakdown from the revenue endpoint
    final rawGroups = (j['groups'] ?? j['trend']) as List?;
    final trend = rawGroups
            ?.map((e) {
              final g = e as Map<String, dynamic>;
              // group item: {label, collected, pending, appointmentCount}
              // time-series item: {date, value}
              final dateStr = g['label'] as String? ?? g['date'] as String? ?? '';
              final value = (g['collected'] ?? g['value'] as num?)?.toDouble() ?? 0;
              return TimeSeriesPointModel(
                date: DateTime.tryParse(dateStr) ?? DateTime.now(),
                value: value,
              );
            })
            .toList() ??
        <TimeSeriesPointModel>[];

    return RevenueSummaryModel(
      totalRevenue: (j['totalRevenue'] ?? j['total_revenue'] as num?)?.toDouble() ?? 0,
      pendingPayments:
          (j['totalPending'] ?? j['pendingPayments'] ?? j['pending_payments'] as num?)?.toDouble() ?? 0,
      refunded: (j['refunded'] as num?)?.toDouble() ?? 0,
      avgPerAppointment: (j['avgPerAppointment'] ?? j['avg_per_appointment'] as num?)?.toDouble() ?? 0,
      prevTotalRevenue: (j['prevTotalRevenue'] ?? j['prev_total_revenue'] as num?)?.toDouble(),
      trend: trend,
      rows: ((j['rows']) as List?)
              ?.map((e) => RevenueRowModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalRows: j['totalRows'] as int? ?? j['total_rows'] as int? ?? 0,
    );
  }
}
