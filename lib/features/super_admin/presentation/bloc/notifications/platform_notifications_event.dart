part of 'platform_notifications_bloc.dart';

abstract class PlatformNotificationsEvent extends Equatable {
  const PlatformNotificationsEvent();
  @override
  List<Object?> get props => [];
}

class PlatformNotificationsStarted extends PlatformNotificationsEvent {
  const PlatformNotificationsStarted();
}

class PlatformNotificationsPageChanged extends PlatformNotificationsEvent {
  final int page;
  const PlatformNotificationsPageChanged(this.page);
  @override
  List<Object?> get props => [page];
}

class PlatformNotificationsRefreshed extends PlatformNotificationsEvent {
  const PlatformNotificationsRefreshed();
}

class PlatformNotificationMarkReadRequested extends PlatformNotificationsEvent {
  final String id;
  const PlatformNotificationMarkReadRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class PlatformNotificationsMarkAllReadRequested extends PlatformNotificationsEvent {
  const PlatformNotificationsMarkAllReadRequested();
}
