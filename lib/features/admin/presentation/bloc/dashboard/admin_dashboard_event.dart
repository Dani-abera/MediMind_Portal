part of 'admin_dashboard_bloc.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();
  @override List<Object?> get props => [];
}

class AdminDashboardStarted extends AdminDashboardEvent {
  const AdminDashboardStarted();
}

class AdminDashboardRefreshed extends AdminDashboardEvent {
  const AdminDashboardRefreshed();
}

class AdminDashboardQueueUpdated extends AdminDashboardEvent {
  final int queueLength;
  const AdminDashboardQueueUpdated(this.queueLength);
  @override List<Object?> get props => [queueLength];
}
