import 'package:equatable/equatable.dart';
import 'analytics_data.dart';

enum RevenueGroupBy { day, week, month }

class RevenueRow extends Equatable {
  final DateTime date;
  final String appointmentId;
  final String doctorName;
  final String patientMasked;
  final double amount;
  final String method;
  final String status;
  const RevenueRow({
    required this.date,
    required this.appointmentId,
    required this.doctorName,
    required this.patientMasked,
    required this.amount,
    required this.method,
    required this.status,
  });
  @override
  List<Object?> get props => [date, appointmentId, doctorName, patientMasked, amount, method, status];
}

class RevenueSummary extends Equatable {
  final double totalRevenue;
  final double pendingPayments;
  final double refunded;
  final double avgPerAppointment;
  final double? prevTotalRevenue;
  final List<TimeSeriesPoint> trend;
  final List<RevenueRow> rows;
  final int totalRows;

  const RevenueSummary({
    this.totalRevenue = 0,
    this.pendingPayments = 0,
    this.refunded = 0,
    this.avgPerAppointment = 0,
    this.prevTotalRevenue,
    this.trend = const [],
    this.rows = const [],
    this.totalRows = 0,
  });

  @override
  List<Object?> get props => [totalRevenue, pendingPayments, refunded, avgPerAppointment,
    prevTotalRevenue, trend, rows, totalRows];
}
