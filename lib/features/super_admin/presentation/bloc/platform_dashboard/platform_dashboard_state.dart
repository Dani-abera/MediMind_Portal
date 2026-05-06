part of 'platform_dashboard_bloc.dart';

abstract class PlatformDashboardState extends Equatable {
  const PlatformDashboardState();
  @override
  List<Object?> get props => [];
}

class PlatformDashboardInitial extends PlatformDashboardState {
  const PlatformDashboardInitial();
}

class PlatformDashboardLoading extends PlatformDashboardState {
  const PlatformDashboardLoading();
}

class PlatformDashboardLoaded extends PlatformDashboardState {
  final PlatformDashboardData data;
  const PlatformDashboardLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class PlatformDashboardError extends PlatformDashboardState {
  final String message;
  const PlatformDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
