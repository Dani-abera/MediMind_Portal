import '../../domain/entities/admin_dashboard_data.dart';
import 'queue_item_model.dart';

class HourlyVolumeModel extends HourlyVolume {
  const HourlyVolumeModel({required super.hour, required super.count});
  factory HourlyVolumeModel.fromJson(Map<String, dynamic> j) =>
      HourlyVolumeModel(hour: j['hour'] as int? ?? 0, count: j['count'] as int? ?? 0);
}

class DoctorUtilizationModel extends DoctorUtilization {
  const DoctorUtilizationModel({
    required super.doctorId,
    required super.doctorName,
    required super.utilizationPercent,
    required super.appointmentsToday,
  });

  factory DoctorUtilizationModel.fromJson(Map<String, dynamic> j) => DoctorUtilizationModel(
        doctorId: j['doctorId'] as String? ?? j['doctor_id'] as String? ?? '',
        doctorName: j['doctorName'] as String? ?? j['doctor_name'] as String? ?? '',
        utilizationPercent: (j['utilizationPercent'] ?? j['utilization_percent'] as num?)?.toDouble() ?? 0,
        appointmentsToday: j['appointmentsToday'] as int? ?? j['appointments_today'] as int? ?? 0,
      );
}

class AdminDashboardDataModel extends AdminDashboardData {
  const AdminDashboardDataModel({
    super.todayAppointmentsTotal,
    super.confirmedCount,
    super.pendingCount,
    super.cancelledCount,
    super.queueLength,
    super.avgWaitMinutes,
    super.todayRevenueEtb,
    super.revenueChangePercent,
    super.activeDoctors,
    super.totalDoctors,
    super.hourlyVolume,
    super.doctorUtilization,
    super.recentQueue,
    super.weeklyAppointments,
  });

  factory AdminDashboardDataModel.fromJson(Map<String, dynamic> j) {
    final appts = j['appointments'] as Map<String, dynamic>? ?? {};
    final queue = j['queue'] as Map<String, dynamic>? ?? {};
    final revenue = j['revenue'] as Map<String, dynamic>? ?? {};
    final doctors = j['doctors'] as Map<String, dynamic>? ?? {};

    return AdminDashboardDataModel(
      todayAppointmentsTotal: appts['total'] as int? ?? j['todayAppointmentsTotal'] as int? ?? 0,
      confirmedCount: appts['confirmed'] as int? ?? j['confirmedCount'] as int? ?? 0,
      pendingCount: appts['pending'] as int? ?? j['pendingCount'] as int? ?? 0,
      cancelledCount: appts['cancelled'] as int? ?? j['cancelledCount'] as int? ?? 0,
      queueLength: queue['length'] as int? ?? j['queueLength'] as int? ?? 0,
      avgWaitMinutes: (queue['avgWait'] ?? j['avgWaitMinutes'] as num?)?.toDouble() ?? 0,
      todayRevenueEtb: (revenue['today'] ?? j['todayRevenueEtb'] as num?)?.toDouble() ?? 0,
      revenueChangePercent: (revenue['changePercent'] ?? j['revenueChangePercent'] as num?)?.toDouble() ?? 0,
      activeDoctors: doctors['active'] as int? ?? j['activeDoctors'] as int? ?? 0,
      totalDoctors: doctors['total'] as int? ?? j['totalDoctors'] as int? ?? 0,
      hourlyVolume: ((j['hourlyVolume'] ?? j['hourly_volume']) as List?)
              ?.map((e) => HourlyVolumeModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      doctorUtilization: ((j['doctorUtilization'] ?? j['doctor_utilization']) as List?)
              ?.map((e) => DoctorUtilizationModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      recentQueue: ((j['recentQueue'] ?? j['recent_queue']) as List?)
              ?.map((e) => QueueItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      weeklyAppointments: ((j['weeklyAppointments'] ?? j['weekly_appointments']) as List?)
              ?.map((e) => e as int)
              .toList() ?? List.filled(7, 0),
    );
  }
}
