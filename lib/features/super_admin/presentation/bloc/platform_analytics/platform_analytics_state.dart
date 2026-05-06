part of 'platform_analytics_bloc.dart';

abstract class PlatformAnalyticsState extends Equatable {
  const PlatformAnalyticsState();
  @override
  List<Object?> get props => [];
}

class PlatformAnalyticsInitial extends PlatformAnalyticsState {
  const PlatformAnalyticsInitial();
}

class PlatformAnalyticsLoading extends PlatformAnalyticsState {
  const PlatformAnalyticsLoading();
}

class PlatformAnalyticsLoaded extends PlatformAnalyticsState {
  final PlatformAnalytics analytics;
  const PlatformAnalyticsLoaded(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

class PlatformAnalyticsError extends PlatformAnalyticsState {
  final String message;
  const PlatformAnalyticsError(this.message);
  @override
  List<Object?> get props => [message];
}
