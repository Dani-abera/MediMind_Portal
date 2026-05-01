import 'package:equatable/equatable.dart';

enum ConsultationStatus {
  pending,
  active,
  ended;

  static ConsultationStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'active' => active,
        'ended' || 'completed' => ended,
        _ => pending,
      };
}

class VideoConsultation extends Equatable {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String patientName;
  final ConsultationStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? signalingRoomId;
  final String? joinToken;

  const VideoConsultation({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.signalingRoomId,
    this.joinToken,
  });

  Duration? get duration => startedAt != null && endedAt != null
      ? endedAt!.difference(startedAt!)
      : startedAt != null
          ? DateTime.now().difference(startedAt!)
          : null;

  @override
  List<Object?> get props => [
        id, appointmentId, doctorId, patientId, patientName,
        status, startedAt, endedAt, signalingRoomId, joinToken,
      ];
}
