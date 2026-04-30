import 'package:equatable/equatable.dart';

enum RealtimeEventType {
  queueUpdate,
  appointmentUpdate,
  consultationUpdate,
  notification,
  connected,
  disconnected,
  unknown,
}

class RealtimeEvent extends Equatable {
  final RealtimeEventType type;
  final String? topic;
  final Map<String, dynamic>? data;

  const RealtimeEvent({required this.type, this.topic, this.data});

  @override
  List<Object?> get props => [type, topic, data];
}
