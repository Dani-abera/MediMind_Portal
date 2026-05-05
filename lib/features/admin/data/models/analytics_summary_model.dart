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
        value: j['value'] as int? ?? 0,
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
    List<TimeSeriesPoint> series(String key) =>
        ((j[key]) as List?)
            ?.map((e) => TimeSeriesPointModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return AnalyticsSummaryModel(
      totalAppointments: j['totalAppointments'] as int? ?? j['total_appointments'] as int? ?? 0,
      completedAppointments: j['completedAppointments'] as int? ?? j['completed_appointments'] as int? ?? 0,
      cancelledAppointments: j['cancelledAppointments'] as int? ?? j['cancelled_appointments'] as int? ?? 0,
      noShowCount: j['noShowCount'] as int? ?? j['no_show_count'] as int? ?? 0,
      noShowRate: (j['noShowRate'] ?? j['no_show_rate'] as num?)?.toDouble() ?? 0,
      totalRevenueEtb: (j['totalRevenueEtb'] ?? j['total_revenue_etb'] as num?)?.toDouble() ?? 0,
      newPatients: j['newPatients'] as int? ?? j['new_patients'] as int? ?? 0,
      doctorUtilizationPercent: (j['doctorUtilizationPercent'] ?? j['doctor_utilization_percent'] as num?)?.toDouble() ?? 0,
      prevTotalAppointments: j['prevTotalAppointments'] as int? ?? j['prev_total_appointments'] as int?,
      prevTotalRevenueEtb: (j['prevTotalRevenueEtb'] ?? j['prev_total_revenue_etb'] as num?)?.toDouble(),
      prevNewPatients: j['prevNewPatients'] as int? ?? j['prev_new_patients'] as int?,
      prevDoctorUtilizationPercent: (j['prevDoctorUtilizationPercent'] ?? j['prev_doctor_utilization_percent'] as num?)?.toDouble(),
      completedTrend: series('completedTrend'),
      cancelledTrend: series('cancelledTrend'),
      noShowTrend: series('noShowTrend'),
      statusDistribution: ((j['statusDistribution'] ?? j['status_distribution']) as Map?)
              ?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ??
          {},
      peakHours: ((j['peakHours'] ?? j['peak_hours']) as List?)
              ?.map((e) => HeatmapCellModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      doctorStats: ((j['doctorStats'] ?? j['doctor_stats']) as List?)
              ?.map((e) => DoctorAnalyticsStatModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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

  factory RevenueSummaryModel.fromJson(Map<String, dynamic> j) => RevenueSummaryModel(
        totalRevenue: (j['totalRevenue'] ?? j['total_revenue'] as num?)?.toDouble() ?? 0,
        pendingPayments: (j['pendingPayments'] ?? j['pending_payments'] as num?)?.toDouble() ?? 0,
        refunded: (j['refunded'] as num?)?.toDouble() ?? 0,
        avgPerAppointment: (j['avgPerAppointment'] ?? j['avg_per_appointment'] as num?)?.toDouble() ?? 0,
        prevTotalRevenue: (j['prevTotalRevenue'] ?? j['prev_total_revenue'] as num?)?.toDouble(),
        trend: ((j['trend']) as List?)
                ?.map((e) => TimeSeriesPointModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        rows: ((j['rows']) as List?)
                ?.map((e) => RevenueRowModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        totalRows: j['totalRows'] as int? ?? j['total_rows'] as int? ?? 0,
      );
}
