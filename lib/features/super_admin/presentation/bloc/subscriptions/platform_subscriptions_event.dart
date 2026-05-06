part of 'platform_subscriptions_bloc.dart';

abstract class PlatformSubscriptionsEvent extends Equatable {
  const PlatformSubscriptionsEvent();
  @override
  List<Object?> get props => [];
}

class PlatformSubscriptionsStarted extends PlatformSubscriptionsEvent {
  final String? planFilter;
  final String? statusFilter;
  const PlatformSubscriptionsStarted({this.planFilter, this.statusFilter});
  @override
  List<Object?> get props => [planFilter, statusFilter];
}

class PlatformSubscriptionsFiltered extends PlatformSubscriptionsEvent {
  final String? planFilter;
  final String? statusFilter;
  const PlatformSubscriptionsFiltered({this.planFilter, this.statusFilter});
  @override
  List<Object?> get props => [planFilter, statusFilter];
}

class PlatformSubscriptionsPageChanged extends PlatformSubscriptionsEvent {
  final int page;
  const PlatformSubscriptionsPageChanged(this.page);
  @override
  List<Object?> get props => [page];
}

class PlatformSubscriptionsRefreshed extends PlatformSubscriptionsEvent {
  const PlatformSubscriptionsRefreshed();
}

class SubscriptionChangePlanRequested extends PlatformSubscriptionsEvent {
  final String centerId;
  final String plan;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  const SubscriptionChangePlanRequested({
    required this.centerId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });
  @override
  List<Object?> get props => [centerId, plan, startDate, endDate, reason];
}
