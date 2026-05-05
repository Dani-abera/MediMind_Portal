part of 'admin_dashboard_bloc.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();
  @override List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminDashboardData data;
  final DateTime lastRefreshed;
  const AdminDashboardLoaded(this.data, this.lastRefreshed);
  @override List<Object?> get props => [data, lastRefreshed];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;
  const AdminDashboardError(this.message);
  @override List<Object?> get props => [message];
}
