import 'package:equatable/equatable.dart';

enum DateRangePreset { today, last7, last30, last90, custom }

class DateRangeSelection extends Equatable {
  final DateRangePreset preset;
  final DateTime from;
  final DateTime to;

  const DateRangeSelection({required this.preset, required this.from, required this.to});

  factory DateRangeSelection.preset(DateRangePreset p) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (p) {
      DateRangePreset.today   => DateRangeSelection(preset: p, from: today, to: today.add(const Duration(days: 1))),
      DateRangePreset.last7   => DateRangeSelection(preset: p, from: today.subtract(const Duration(days: 6)), to: today.add(const Duration(days: 1))),
      DateRangePreset.last30  => DateRangeSelection(preset: p, from: today.subtract(const Duration(days: 29)), to: today.add(const Duration(days: 1))),
      DateRangePreset.last90  => DateRangeSelection(preset: p, from: today.subtract(const Duration(days: 89)), to: today.add(const Duration(days: 1))),
      DateRangePreset.custom  => DateRangeSelection(preset: p, from: today.subtract(const Duration(days: 29)), to: today.add(const Duration(days: 1))),
    };
  }

  String get label => switch (preset) {
    DateRangePreset.today  => 'Today',
    DateRangePreset.last7  => 'Last 7 days',
    DateRangePreset.last30 => 'Last 30 days',
    DateRangePreset.last90 => 'Last 90 days',
    DateRangePreset.custom => 'Custom',
  };

  @override
  List<Object?> get props => [preset, from, to];
}

class TimeSeriesPoint extends Equatable {
  final DateTime date;
  final double value;
  final String? series;
  const TimeSeriesPoint({required this.date, required this.value, this.series});
  @override
  List<Object?> get props => [date, value, series];
}

class HeatmapCell extends Equatable {
  final int dayOfWeek; // 0=Mon … 6=Sun
  final int hour;      // 0–23
  final int value;
  const HeatmapCell({required this.dayOfWeek, required this.hour, required this.value});
  @override
  List<Object?> get props => [dayOfWeek, hour, value];
}

class DoctorAnalyticsStat extends Equatable {
  final String doctorId;
  final String doctorName;
  final double noShowRate;
  final double utilizationPercent;
  final double revenueEtb;
  final double avgWaitMinutes;
  const DoctorAnalyticsStat({
    required this.doctorId,
    required this.doctorName,
    required this.noShowRate,
    required this.utilizationPercent,
    required this.revenueEtb,
    required this.avgWaitMinutes,
  });
  @override
  List<Object?> get props => [doctorId, doctorName, noShowRate, utilizationPercent, revenueEtb, avgWaitMinutes];
}

class AnalyticsSummary extends Equatable {
  // KPIs
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int noShowCount;
  final double noShowRate;
  final double totalRevenueEtb;
  final int newPatients;
  final double doctorUtilizationPercent;
  // Comparison values (previous period)
  final int? prevTotalAppointments;
  final double? prevTotalRevenueEtb;
  final int? prevNewPatients;
  final double? prevDoctorUtilizationPercent;
  // Chart data
  final List<TimeSeriesPoint> completedTrend;
  final List<TimeSeriesPoint> cancelledTrend;
  final List<TimeSeriesPoint> noShowTrend;
  final Map<String, int> statusDistribution;
  final List<HeatmapCell> peakHours;
  final List<DoctorAnalyticsStat> doctorStats;
  final List<TimeSeriesPoint> avgWaitTimeTrend;

  const AnalyticsSummary({
    this.totalAppointments = 0,
    this.completedAppointments = 0,
    this.cancelledAppointments = 0,
    this.noShowCount = 0,
    this.noShowRate = 0,
    this.totalRevenueEtb = 0,
    this.newPatients = 0,
    this.doctorUtilizationPercent = 0,
    this.prevTotalAppointments,
    this.prevTotalRevenueEtb,
    this.prevNewPatients,
    this.prevDoctorUtilizationPercent,
    this.completedTrend = const [],
    this.cancelledTrend = const [],
    this.noShowTrend = const [],
    this.statusDistribution = const {},
    this.peakHours = const [],
    this.doctorStats = const [],
    this.avgWaitTimeTrend = const [],
  });

  @override
  List<Object?> get props => [
    totalAppointments, completedAppointments, cancelledAppointments, noShowCount,
    noShowRate, totalRevenueEtb, newPatients, doctorUtilizationPercent,
    prevTotalAppointments, prevTotalRevenueEtb, prevNewPatients,
    completedTrend, cancelledTrend, noShowTrend, statusDistribution,
    peakHours, doctorStats, avgWaitTimeTrend,
  ];
}

class DoctorReview extends Equatable {
  final String patientName;
  final double rating;
  final String? comment;
  final DateTime date;
  const DoctorReview({required this.patientName, required this.rating, this.comment, required this.date});
  @override
  List<Object?> get props => [patientName, rating, comment, date];
}

class TopPatientRow extends Equatable {
  final String patientName;
  final int visitCount;
  final double totalSpentEtb;
  final DateTime lastVisit;
  const TopPatientRow({required this.patientName, required this.visitCount, required this.totalSpentEtb, required this.lastVisit});
  @override
  List<Object?> get props => [patientName, visitCount, totalSpentEtb, lastVisit];
}

class DoctorAnalyticsDetail extends Equatable {
  final String doctorId;
  final String doctorName;
  final int totalAppointments;
  final double completionRate;
  final double avgRating;
  final double totalRevenueEtb;
  final List<TimeSeriesPoint> volumeTrend;
  final List<double> dayOfWeekPattern; // 7 values Mon-Sun
  final List<double> hourOfDayPattern; // 24 values
  final List<TopPatientRow> topPatients;
  final List<DoctorReview> recentReviews;

  const DoctorAnalyticsDetail({
    required this.doctorId,
    required this.doctorName,
    this.totalAppointments = 0,
    this.completionRate = 0,
    this.avgRating = 0,
    this.totalRevenueEtb = 0,
    this.volumeTrend = const [],
    this.dayOfWeekPattern = const [],
    this.hourOfDayPattern = const [],
    this.topPatients = const [],
    this.recentReviews = const [],
  });

  @override
  List<Object?> get props => [doctorId, doctorName, totalAppointments, completionRate,
    avgRating, totalRevenueEtb, volumeTrend, dayOfWeekPattern, hourOfDayPattern,
    topPatients, recentReviews];
}
