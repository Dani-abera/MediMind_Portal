import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/realtime_event.dart';
import '../../core/network/realtime_service.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationStarted extends NotificationEvent {
  const NotificationStarted();
}

class _NotificationPollTicked extends NotificationEvent {
  const _NotificationPollTicked();
}

class _NotificationPushReceived extends NotificationEvent {
  final Map<String, dynamic>? data;
  const _NotificationPushReceived(this.data);
  @override
  List<Object?> get props => [data];
}

// ── State ────────────────────────────────────────────────────────────────────

class NotificationState extends Equatable {
  final int unreadCount;
  final List<Map<String, dynamic>> recent;

  const NotificationState({this.unreadCount = 0, this.recent = const []});

  NotificationState copyWith({
    int? unreadCount,
    List<Map<String, dynamic>>? recent,
  }) =>
      NotificationState(
        unreadCount: unreadCount ?? this.unreadCount,
        recent: recent ?? this.recent,
      );

  @override
  List<Object?> get props => [unreadCount, recent];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final DioClient _client;
  final RealtimeService _realtime;
  Timer? _timer;
  StreamSubscription<RealtimeEvent>? _realtimeSub;

  NotificationBloc({
    required DioClient client,
    required RealtimeService realtime,
  })  : _client = client,
        _realtime = realtime,
        super(const NotificationState()) {
    on<NotificationStarted>(_onStarted);
    on<_NotificationPollTicked>(_onTick);
    on<_NotificationPushReceived>(_onPush);
  }

  void _onStarted(NotificationStarted _, Emitter<NotificationState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => add(const _NotificationPollTicked()),
    );
    _realtimeSub = _realtime.events.listen((e) {
      if (e.type == RealtimeEventType.notification) {
        add(_NotificationPushReceived(e.data));
      }
    });
    add(const _NotificationPollTicked());
  }

  Future<void> _onTick(
    _NotificationPollTicked _,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final resp =
          await _client.dio.get('/notifications/unread-count');
      final count = (resp.data['data'] ?? 0) as int;
      emit(state.copyWith(unreadCount: count));
    } catch (_) {
      // silently ignore
    }
  }

  void _onPush(
    _NotificationPushReceived event,
    Emitter<NotificationState> emit,
  ) {
    final recent = [
      if (event.data != null) event.data!,
      ...state.recent,
    ].take(10).toList();
    emit(state.copyWith(
      unreadCount: state.unreadCount + 1,
      recent: recent,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _realtimeSub?.cancel();
    return super.close();
  }
}
