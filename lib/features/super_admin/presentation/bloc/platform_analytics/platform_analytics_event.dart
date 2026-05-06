part of 'platform_analytics_bloc.dart';

abstract class PlatformAnalyticsEvent extends Equatable {
  const PlatformAnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class PlatformAnalyticsStarted extends PlatformAnalyticsEvent {
  const PlatformAnalyticsStarted();
}

class PlatformAnalyticsPeriodChanged extends PlatformAnalyticsEvent {
  final String period;
  const PlatformAnalyticsPeriodChanged(this.period);
  @override
  List<Object?> get props => [period];
}
