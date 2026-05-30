part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsStarted extends NotificationsEvent {
  const NotificationsStarted();
}

class NotificationsRefreshed extends NotificationsEvent {
  const NotificationsRefreshed();
}

class NotificationMarkReadRequested extends NotificationsEvent {
  final String id;
  const NotificationMarkReadRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class NotificationsMarkAllReadRequested extends NotificationsEvent {
  const NotificationsMarkAllReadRequested();
}
