part of 'analytics_dashboard_bloc.dart';

abstract class AnalyticsDashboardEvent extends Equatable {
  const AnalyticsDashboardEvent();
  @override List<Object?> get props => [];
}

class AnalyticsDashboardStarted extends AnalyticsDashboardEvent {
  final String centerId;
  final DateRangePreset preset;
  const AnalyticsDashboardStarted(this.centerId, {this.preset = DateRangePreset.last30});
  @override List<Object?> get props => [centerId, preset];
}

class AnalyticsDateRangeChanged extends AnalyticsDashboardEvent {
  final DateRangePreset preset;
  final DateTime? customFrom;
  final DateTime? customTo;
  const AnalyticsDateRangeChanged(this.preset, {this.customFrom, this.customTo});
  @override List<Object?> get props => [preset, customFrom, customTo];
}

class AnalyticsComparePeriodToggled extends AnalyticsDashboardEvent {
  final bool enabled;
  const AnalyticsComparePeriodToggled(this.enabled);
  @override List<Object?> get props => [enabled];
}

class AnalyticsExportRequested extends AnalyticsDashboardEvent {
  final ExportFormat format;
  const AnalyticsExportRequested(this.format);
  @override List<Object?> get props => [format];
}

class AnalyticsDashboardRefreshed extends AnalyticsDashboardEvent {
  const AnalyticsDashboardRefreshed();
}
