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

    int parseInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
    double parseDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;

    return AdminDashboardDataModel(
      todayAppointmentsTotal: parseInt(appts['total'] ?? j['todayAppointmentsTotal']),
      confirmedCount: parseInt(appts['confirmed'] ?? j['confirmedCount']),
      pendingCount: parseInt(appts['pending'] ?? j['pendingCount']),
      cancelledCount: parseInt(appts['cancelled'] ?? j['cancelledCount']),
      queueLength: parseInt(queue['currentlyWaiting'] ?? queue['length'] ?? j['queueLength']),
      avgWaitMinutes: parseDouble(queue['averageWaitMinutes'] ?? queue['avgWait'] ?? j['avgWaitMinutes']),
      todayRevenueEtb: parseDouble(revenue['totalCollected'] ?? revenue['today'] ?? j['todayRevenueEtb']),
      revenueChangePercent: parseDouble(revenue['changePercent'] ?? j['revenueChangePercent']),
      activeDoctors: parseInt(doctors['working'] ?? doctors['active'] ?? j['activeDoctors']),
      totalDoctors: parseInt(doctors['totalRegistered'] ?? doctors['total'] ?? j['totalDoctors']),
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
