part of 'platform_dashboard_bloc.dart';

abstract class PlatformDashboardEvent extends Equatable {
  const PlatformDashboardEvent();
  @override
  List<Object?> get props => [];
}

class PlatformDashboardStarted extends PlatformDashboardEvent {
  const PlatformDashboardStarted();
}

class PlatformDashboardRefreshed extends PlatformDashboardEvent {
  const PlatformDashboardRefreshed();
}
