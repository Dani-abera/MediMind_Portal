import 'package:equatable/equatable.dart';
import 'queue_item.dart';

class HourlyVolume extends Equatable {
  final int hour;
  final int count;
  const HourlyVolume({required this.hour, required this.count});
  @override
  List<Object?> get props => [hour, count];
}

class DoctorUtilization extends Equatable {
  final String doctorId;
  final String doctorName;
  final double utilizationPercent;
  final int appointmentsToday;

  const DoctorUtilization({
    required this.doctorId,
    required this.doctorName,
    required this.utilizationPercent,
    required this.appointmentsToday,
  });

  @override
  List<Object?> get props => [doctorId, doctorName, utilizationPercent, appointmentsToday];
}

class AdminDashboardData extends Equatable {
  final int todayAppointmentsTotal;
  final int confirmedCount;
  final int pendingCount;
  final int cancelledCount;
  final int queueLength;
  final double avgWaitMinutes;
  final double todayRevenueEtb;
  final double revenueChangePercent;
  final int activeDoctors;
  final int totalDoctors;
  final List<HourlyVolume> hourlyVolume;
  final List<DoctorUtilization> doctorUtilization;
  final List<QueueItem> recentQueue;
  final List<int> weeklyAppointments;

  const AdminDashboardData({
    this.todayAppointmentsTotal = 0,
    this.confirmedCount = 0,
    this.pendingCount = 0,
    this.cancelledCount = 0,
    this.queueLength = 0,
    this.avgWaitMinutes = 0,
    this.todayRevenueEtb = 0,
    this.revenueChangePercent = 0,
    this.activeDoctors = 0,
    this.totalDoctors = 0,
    this.hourlyVolume = const [],
    this.doctorUtilization = const [],
    this.recentQueue = const [],
    this.weeklyAppointments = const [],
  });

  AdminDashboardData copyWith({int? queueLength}) => AdminDashboardData(
        todayAppointmentsTotal: todayAppointmentsTotal,
        confirmedCount: confirmedCount,
        pendingCount: pendingCount,
        cancelledCount: cancelledCount,
        queueLength: queueLength ?? this.queueLength,
        avgWaitMinutes: avgWaitMinutes,
        todayRevenueEtb: todayRevenueEtb,
        revenueChangePercent: revenueChangePercent,
        activeDoctors: activeDoctors,
        totalDoctors: totalDoctors,
        hourlyVolume: hourlyVolume,
        doctorUtilization: doctorUtilization,
        recentQueue: recentQueue,
        weeklyAppointments: weeklyAppointments,
      );

  @override
  List<Object?> get props => [
        todayAppointmentsTotal, confirmedCount, pendingCount, cancelledCount,
        queueLength, avgWaitMinutes, todayRevenueEtb, revenueChangePercent,
        activeDoctors, totalDoctors, hourlyVolume, doctorUtilization,
        recentQueue, weeklyAppointments,
      ];
}
