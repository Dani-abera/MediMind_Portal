part of 'platform_users_bloc.dart';

abstract class PlatformUsersState extends Equatable {
  const PlatformUsersState();
  @override
  List<Object?> get props => [];
}

class PlatformUsersInitial extends PlatformUsersState {
  const PlatformUsersInitial();
}

class PlatformUsersLoading extends PlatformUsersState {
  const PlatformUsersLoading();
}

class PlatformUsersLoaded extends PlatformUsersState {
  final List<PlatformUser> users;
  final int total;
  final int page;
  const PlatformUsersLoaded({required this.users, required this.total, this.page = 1});
  @override
  List<Object?> get props => [users, total, page];
}

class PlatformUsersActionSuccess extends PlatformUsersState {
  final String message;
  const PlatformUsersActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PlatformUsersActionError extends PlatformUsersState {
  final String message;
  const PlatformUsersActionError(this.message);
  @override
  List<Object?> get props => [message];
}

class PlatformUsersError extends PlatformUsersState {
  final String message;
  const PlatformUsersError(this.message);
  @override
  List<Object?> get props => [message];
}
