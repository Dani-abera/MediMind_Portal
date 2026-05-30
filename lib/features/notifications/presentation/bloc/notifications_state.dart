part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationItem> items;
  const NotificationsLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class NotificationsActionSuccess extends NotificationsState {
  final String message;
  const NotificationsActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationsActionError extends NotificationsState {
  final String message;
  const NotificationsActionError(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
  @override
  List<Object?> get props => [message];
}
