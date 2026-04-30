import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'realtime_event.dart';
import 'user_context.dart';

class RealtimeService {
  HubConnection? _hub;
  final _controller = StreamController<RealtimeEvent>.broadcast();
  final UserContext _ctx;
  bool _disposed = false;
  int _retryCount = 0;

  RealtimeService(this._ctx);

  Stream<RealtimeEvent> get events => _controller.stream;

  bool get isConnected =>
      _hub?.state == HubConnectionState.Connected;

  Future<void> connect() async {
    if (_disposed) return;
    final base = dotenv.env['SIGNALR_BASE_URL'] ?? 'https://api.medimind.et';
    final url = '$base/hubs/portal';

    _hub = HubConnectionBuilder()
        .withUrl(url,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => _ctx.accessToken ?? '',
            ))
        .withAutomaticReconnect(retryDelays: _retryDelays())
        .build();

    _hub!.onreconnecting(({error}) {
      _controller.add(const RealtimeEvent(type: RealtimeEventType.disconnected));
    });

    _hub!.onreconnected(({connectionId}) {
      _retryCount = 0;
      _controller.add(const RealtimeEvent(type: RealtimeEventType.connected));
    });

    _hub!.onclose(({error}) {
      if (!_disposed) {
        _scheduleReconnect();
      }
    });

    _registerHandlers();

    try {
      await _hub!.start();
      _retryCount = 0;
      _controller.add(const RealtimeEvent(type: RealtimeEventType.connected));
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _registerHandlers() {
    _hub?.on('QueueUpdated', (args) {
      _emit(RealtimeEventType.queueUpdate, args);
    });
    _hub?.on('AppointmentUpdated', (args) {
      _emit(RealtimeEventType.appointmentUpdate, args);
    });
    _hub?.on('ConsultationUpdated', (args) {
      _emit(RealtimeEventType.consultationUpdate, args);
    });
    _hub?.on('Notification', (args) {
      _emit(RealtimeEventType.notification, args);
    });
  }

  void _emit(RealtimeEventType type, List<Object?>? args) {
    if (_disposed) return;
    final data = args?.isNotEmpty == true && args!.first is Map
        ? Map<String, dynamic>.from(args.first as Map)
        : null;
    _controller.add(RealtimeEvent(type: type, data: data));
  }

  Future<void> joinCenterGroup(String centerId) async {
    if (!isConnected) return;
    await _hub?.invoke('JoinCenterGroup', args: [centerId]);
  }

  Future<void> joinQueueGroup(String centerId) async {
    if (!isConnected) return;
    await _hub?.invoke('JoinQueueGroup', args: [centerId]);
  }

  Future<void> joinVideoRoom(String consultationId) async {
    if (!isConnected) return;
    await _hub?.invoke('JoinVideoRoom', args: [consultationId]);
  }

  Future<void> disconnect() async {
    await _hub?.stop();
    _hub = null;
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    final delay = _backoff(_retryCount++);
    Future.delayed(delay, () {
      if (!_disposed && !isConnected) connect();
    });
  }

  Duration _backoff(int attempt) {
    final seconds = [2, 5, 10, 20, 30, 60];
    final idx = attempt.clamp(0, seconds.length - 1);
    return Duration(seconds: seconds[idx]);
  }

  List<int> _retryDelays() => [2000, 5000, 10000, 20000, 30000];

  void dispose() {
    _disposed = true;
    _controller.close();
    _hub?.stop();
  }
}
