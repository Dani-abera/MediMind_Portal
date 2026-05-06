import 'package:equatable/equatable.dart';

class ChartPoint extends Equatable {
  final DateTime date;
  final int centers;
  final int doctors;
  final int patients;

  const ChartPoint({
    required this.date,
    this.centers = 0,
    this.doctors = 0,
    this.patients = 0,
  });

  @override
  List<Object?> get props => [date, centers, doctors, patients];
}

class CenterRevenue extends Equatable {
  final String centerId;
  final String centerName;
  final double revenueEtb;

  const CenterRevenue({
    required this.centerId,
    required this.centerName,
    this.revenueEtb = 0,
  });

  @override
  List<Object?> get props => [centerId, centerName, revenueEtb];
}

class PlatformDashboardData extends Equatable {
  final int totalCenters;
  final int activeCenters;
  final int totalDoctors;
  final int verifiedDoctors;
  final int totalPatients;
  final int mau;
  final double monthlyRevenueEtb;
  final int openTickets;
  final int pendingApprovals;
  final int pendingLicenses;
  final List<ChartPoint> platformGrowth;
  final List<CenterRevenue> topCentersByRevenue;
  final Map<String, int> subscriptionBreakdown;

  const PlatformDashboardData({
    this.totalCenters = 0,
    this.activeCenters = 0,
    this.totalDoctors = 0,
    this.verifiedDoctors = 0,
    this.totalPatients = 0,
    this.mau = 0,
    this.monthlyRevenueEtb = 0,
    this.openTickets = 0,
    this.pendingApprovals = 0,
    this.pendingLicenses = 0,
    this.platformGrowth = const [],
    this.topCentersByRevenue = const [],
    this.subscriptionBreakdown = const {},
  });

  @override
  List<Object?> get props => [
        totalCenters, activeCenters, totalDoctors, verifiedDoctors,
        totalPatients, mau, monthlyRevenueEtb, openTickets,
        pendingApprovals, pendingLicenses, platformGrowth,
        topCentersByRevenue, subscriptionBreakdown,
      ];
}
