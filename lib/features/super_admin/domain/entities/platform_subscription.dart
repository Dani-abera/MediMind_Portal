import 'package:equatable/equatable.dart';

class PlatformSubscription extends Equatable {
  final String centerId;
  final String centerName;
  final String plan;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final double mrrEtb;
  final DateTime? lastPaymentAt;
  final int daysRemaining;

  const PlatformSubscription({
    this.centerId = '',
    this.centerName = '',
    this.plan = 'trial',
    this.status = 'active',
    required this.startDate,
    required this.endDate,
    this.mrrEtb = 0,
    this.lastPaymentAt,
    this.daysRemaining = 0,
  });

  @override
  List<Object?> get props => [
        centerId, centerName, plan, status, startDate, endDate,
        mrrEtb, lastPaymentAt, daysRemaining,
      ];
}
