part of 'platform_subscriptions_bloc.dart';

abstract class PlatformSubscriptionsState extends Equatable {
  const PlatformSubscriptionsState();
  @override
  List<Object?> get props => [];
}

class PlatformSubscriptionsInitial extends PlatformSubscriptionsState {
  const PlatformSubscriptionsInitial();
}

class PlatformSubscriptionsLoading extends PlatformSubscriptionsState {
  const PlatformSubscriptionsLoading();
}

class PlatformSubscriptionsLoaded extends PlatformSubscriptionsState {
  final List<PlatformSubscription> subscriptions;
  final int total;
  final int page;
  const PlatformSubscriptionsLoaded({required this.subscriptions, required this.total, this.page = 1});
  @override
  List<Object?> get props => [subscriptions, total, page];
}

class PlatformSubscriptionsActionSuccess extends PlatformSubscriptionsState {
  final String message;
  const PlatformSubscriptionsActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PlatformSubscriptionsActionError extends PlatformSubscriptionsState {
  final String message;
  const PlatformSubscriptionsActionError(this.message);
  @override
  List<Object?> get props => [message];
}

class PlatformSubscriptionsError extends PlatformSubscriptionsState {
  final String message;
  const PlatformSubscriptionsError(this.message);
  @override
  List<Object?> get props => [message];
}
