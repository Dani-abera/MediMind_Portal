part of 'platform_notifications_bloc.dart';

abstract class PlatformNotificationsState extends Equatable {
  const PlatformNotificationsState();
  @override
  List<Object?> get props => [];
}

class PlatformNotificationsInitial extends PlatformNotificationsState {
  const PlatformNotificationsInitial();
}

class PlatformNotificationsLoading extends PlatformNotificationsState {
  const PlatformNotificationsLoading();
}

class PlatformNotificationsLoaded extends PlatformNotificationsState {
  final List<PlatformNotification> items;
  final int total;
  final int page;
  const PlatformNotificationsLoaded({required this.items, required this.total, this.page = 1});
  @override
  List<Object?> get props => [items, total, page];
}

class PlatformNotificationsActionSuccess extends PlatformNotificationsState {
  final String message;
  const PlatformNotificationsActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PlatformNotificationsActionError extends PlatformNotificationsState {
  final String message;
  const PlatformNotificationsActionError(this.message);
  @override
  List<Object?> get props => [message];
}

class PlatformNotificationsError extends PlatformNotificationsState {
  final String message;
  const PlatformNotificationsError(this.message);
  @override
  List<Object?> get props => [message];
}
