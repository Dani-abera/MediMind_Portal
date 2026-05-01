import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../network/realtime_event.dart';
import '../../../network/realtime_service.dart';
import '../../../storage/preferences_storage.dart';
import 'shell_event.dart';
import 'shell_state.dart';

class ShellBloc extends Bloc<ShellEvent, ShellState> {
  final PreferencesStorage _prefs;
  final RealtimeService _realtime;
  StreamSubscription<RealtimeEvent>? _realtimeSub;
  final Map<String, String> _breadcrumbOverrides = {};

  static const _skipSegments = {'doctor', 'admin', 'super-admin'};

  ShellBloc({
    required PreferencesStorage prefs,
    required RealtimeService realtime,
  })  : _prefs = prefs,
        _realtime = realtime,
        super(ShellState(sidebarCollapsed: prefs.getSidebarCollapsed())) {
    on<SidebarToggled>(_onSidebarToggled);
    on<RouteChanged>(_onRouteChanged);
    on<BreadcrumbOverrideRequested>(_onBreadcrumbOverride);
    on<NotificationCountUpdated>(_onNotificationCount);
    on<ConnectionStatusUpdated>(_onConnectionStatus);
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    if (_realtime.isConnected) {
      add(const ConnectionStatusUpdated(AppConnectionStatus.connected));
    }
    _realtimeSub = _realtime.events.listen((event) {
      switch (event.type) {
        case RealtimeEventType.connected:
          add(const ConnectionStatusUpdated(AppConnectionStatus.connected));
        case RealtimeEventType.disconnected:
          add(const ConnectionStatusUpdated(AppConnectionStatus.reconnecting));
        default:
          break;
      }
    });
  }

  void _onSidebarToggled(SidebarToggled _, Emitter<ShellState> emit) {
    final next = !state.sidebarCollapsed;
    _prefs.setSidebarCollapsed(next);
    emit(state.copyWith(sidebarCollapsed: next));
  }

  void _onRouteChanged(RouteChanged event, Emitter<ShellState> emit) {
    final crumbs = _buildBreadcrumbs(event.route);
    emit(state.copyWith(currentRoute: event.route, breadcrumbs: crumbs));
  }

  void _onBreadcrumbOverride(
    BreadcrumbOverrideRequested event,
    Emitter<ShellState> emit,
  ) {
    _breadcrumbOverrides[event.routeSegment] = event.displayName;
    final crumbs = _buildBreadcrumbs(state.currentRoute);
    emit(state.copyWith(breadcrumbs: crumbs));
  }

  void _onNotificationCount(NotificationCountUpdated event, Emitter<ShellState> emit) {
    emit(state.copyWith(unreadNotificationCount: event.count));
  }

  void _onConnectionStatus(ConnectionStatusUpdated event, Emitter<ShellState> emit) {
    emit(state.copyWith(connectionStatus: event.status));
  }

  List<BreadcrumbSegment> _buildBreadcrumbs(String path) {
    final parts = path.split('/').where((s) => s.isNotEmpty).toList();
    final crumbs = <BreadcrumbSegment>[];
    var accRoute = '';
    for (final part in parts) {
      accRoute = '$accRoute/$part';
      if (_skipSegments.contains(part)) continue;
      final label = _breadcrumbOverrides[part] ?? _formatSegment(part);
      crumbs.add(BreadcrumbSegment(label: label, route: accRoute));
    }
    return crumbs;
  }

  String _formatSegment(String s) => s
      .split('-')
      .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
      .join(' ');

  @override
  Future<void> close() {
    _realtimeSub?.cancel();
    return super.close();
  }
}
