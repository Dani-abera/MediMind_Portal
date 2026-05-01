import 'package:equatable/equatable.dart';
import 'shell_event.dart';

class BreadcrumbSegment extends Equatable {
  final String label;
  final String route;
  const BreadcrumbSegment({required this.label, required this.route});
  @override
  List<Object?> get props => [label, route];
}

class ShellState extends Equatable {
  final bool sidebarCollapsed;
  final String currentRoute;
  final List<BreadcrumbSegment> breadcrumbs;
  final int unreadNotificationCount;
  final AppConnectionStatus connectionStatus;

  const ShellState({
    this.sidebarCollapsed = false,
    this.currentRoute = '/',
    this.breadcrumbs = const [],
    this.unreadNotificationCount = 0,
    this.connectionStatus = AppConnectionStatus.offline,
  });

  ShellState copyWith({
    bool? sidebarCollapsed,
    String? currentRoute,
    List<BreadcrumbSegment>? breadcrumbs,
    int? unreadNotificationCount,
    AppConnectionStatus? connectionStatus,
  }) {
    return ShellState(
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
      currentRoute: currentRoute ?? this.currentRoute,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
      unreadNotificationCount:
          unreadNotificationCount ?? this.unreadNotificationCount,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }

  @override
  List<Object?> get props => [
        sidebarCollapsed,
        currentRoute,
        breadcrumbs,
        unreadNotificationCount,
        connectionStatus,
      ];
}
