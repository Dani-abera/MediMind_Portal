part of 'analytics_dashboard_bloc.dart';

abstract class AnalyticsDashboardState extends Equatable {
  const AnalyticsDashboardState();
  @override List<Object?> get props => [];
}

class AnalyticsDashboardInitial extends AnalyticsDashboardState {
  const AnalyticsDashboardInitial();
}

class AnalyticsDashboardLoading extends AnalyticsDashboardState {
  const AnalyticsDashboardLoading();
}

class AnalyticsDashboardLoaded extends AnalyticsDashboardState {
  final AnalyticsSummary data;
  final DateRangeSelection range;
  final bool comparePeriod;
  const AnalyticsDashboardLoaded({
    required this.data,
    required this.range,
    this.comparePeriod = false,
  });
  @override List<Object?> get props => [data, range, comparePeriod];
}

class AnalyticsDashboardError extends AnalyticsDashboardState {
  final String message;
  const AnalyticsDashboardError(this.message);
  @override List<Object?> get props => [message];
}

class AnalyticsExporting extends AnalyticsDashboardState {
  const AnalyticsExporting();
}

class AnalyticsExportDone extends AnalyticsDashboardState {
  final String? url;
  const AnalyticsExportDone({this.url});
  @override List<Object?> get props => [url];
}

class AnalyticsExportError extends AnalyticsDashboardState {
  final String message;
  const AnalyticsExportError(this.message);
  @override List<Object?> get props => [message];
}
