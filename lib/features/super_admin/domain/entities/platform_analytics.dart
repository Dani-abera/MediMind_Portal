import 'package:equatable/equatable.dart';

class RevenueByCenter extends Equatable {
  final String centerId;
  final String centerName;
  final double revenueEtb;

  const RevenueByCenter({
    required this.centerId,
    required this.centerName,
    this.revenueEtb = 0,
  });

  @override
  List<Object?> get props => [centerId, centerName, revenueEtb];
}

class PlatformAnalytics extends Equatable {
  final double totalRevenueEtb;
  final List<RevenueByCenter> revenueByCenterTop20;
  final Map<String, double> revenueByMonth;
  final Map<String, int> newCentersPerMonth;
  final Map<String, int> newDoctorsPerMonth;
  final Map<String, int> newPatientsPerMonth;
  final double churnRate30d;
  final double churnRate60d;
  final double churnRate90d;

  const PlatformAnalytics({
    this.totalRevenueEtb = 0,
    this.revenueByCenterTop20 = const [],
    this.revenueByMonth = const {},
    this.newCentersPerMonth = const {},
    this.newDoctorsPerMonth = const {},
    this.newPatientsPerMonth = const {},
    this.churnRate30d = 0,
    this.churnRate60d = 0,
    this.churnRate90d = 0,
  });

  @override
  List<Object?> get props => [
        totalRevenueEtb, revenueByCenterTop20, revenueByMonth,
        newCentersPerMonth, newDoctorsPerMonth, newPatientsPerMonth,
        churnRate30d, churnRate60d, churnRate90d,
      ];
}
