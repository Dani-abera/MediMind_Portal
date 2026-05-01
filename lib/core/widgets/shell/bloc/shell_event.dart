import 'package:equatable/equatable.dart';

abstract class ShellEvent extends Equatable {
  const ShellEvent();
  @override
  List<Object?> get props => [];
}

class SidebarToggled extends ShellEvent {
  const SidebarToggled();
}

class RouteChanged extends ShellEvent {
  final String route;
  const RouteChanged(this.route);
  @override
  List<Object?> get props => [route];
}

class BreadcrumbOverrideRequested extends ShellEvent {
  final String routeSegment;
  final String displayName;
  const BreadcrumbOverrideRequested({
    required this.routeSegment,
    required this.displayName,
  });
  @override
  List<Object?> get props => [routeSegment, displayName];
}

class NotificationCountUpdated extends ShellEvent {
  final int count;
  const NotificationCountUpdated(this.count);
  @override
  List<Object?> get props => [count];
}

class ConnectionStatusUpdated extends ShellEvent {
  final AppConnectionStatus status;
  const ConnectionStatusUpdated(this.status);
  @override
  List<Object?> get props => [status];
}

enum AppConnectionStatus { connected, reconnecting, offline }
