import 'package:equatable/equatable.dart';

enum QueueStatus {
  waiting,
  inProgress,
  done,
  skipped;

  static QueueStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'inprogress' || 'in_progress' => inProgress,
        'done' || 'completed' => done,
        'skipped' => skipped,
        _ => waiting,
      };
}

class QueueEntry extends Equatable {
  final String id;
  final int queueNumber;
  final String patientId;
  final String patientName;
  final int? patientAge;
  final String appointmentId;
  final DateTime appointmentTime;
  final String reason;
  final QueueStatus status;
  final DateTime? startedAt;

  const QueueEntry({
    required this.id,
    required this.queueNumber,
    required this.patientId,
    required this.patientName,
    this.patientAge,
    required this.appointmentId,
    required this.appointmentTime,
    required this.reason,
    required this.status,
    this.startedAt,
  });

  @override
  List<Object?> get props => [
        id, queueNumber, patientId, patientName, patientAge,
        appointmentId, appointmentTime, reason, status, startedAt,
      ];
}
