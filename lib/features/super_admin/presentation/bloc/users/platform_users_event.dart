part of 'platform_users_bloc.dart';

abstract class PlatformUsersEvent extends Equatable {
  const PlatformUsersEvent();
  @override
  List<Object?> get props => [];
}

class PlatformUsersStarted extends PlatformUsersEvent {
  final String? userTypeFilter;
  final String? statusFilter;
  const PlatformUsersStarted({this.userTypeFilter, this.statusFilter});
  @override
  List<Object?> get props => [userTypeFilter, statusFilter];
}

class PlatformUsersFiltered extends PlatformUsersEvent {
  final String? userTypeFilter;
  final String? statusFilter;
  const PlatformUsersFiltered({this.userTypeFilter, this.statusFilter});
  @override
  List<Object?> get props => [userTypeFilter, statusFilter];
}

class PlatformUsersPageChanged extends PlatformUsersEvent {
  final int page;
  const PlatformUsersPageChanged(this.page);
  @override
  List<Object?> get props => [page];
}

class PlatformUsersRefreshed extends PlatformUsersEvent {
  const PlatformUsersRefreshed();
}

class UserSuspendRequested extends PlatformUsersEvent {
  final String userId;
  final String reason;
  const UserSuspendRequested(this.userId, this.reason);
  @override
  List<Object?> get props => [userId, reason];
}

class UserReactivateRequested extends PlatformUsersEvent {
  final String userId;
  const UserReactivateRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class UserForceLogoutRequested extends PlatformUsersEvent {
  final String userId;
  const UserForceLogoutRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class UserDeleteRequested extends PlatformUsersEvent {
  final String userId;
  const UserDeleteRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}
