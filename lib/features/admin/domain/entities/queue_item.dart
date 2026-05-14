import 'package:equatable/equatable.dart';

enum QueueStatus {
  waiting,
  inProgress,
  done,
  noShow,
  skipped;

  static QueueStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'inprogress' || 'in_progress' || 'inconsultation' || 'in_consultation' => inProgress,
        'called' => inProgress,
        'done' || 'completed' => done,
        'noshow' || 'no_show' || 'missed' => noShow,
        'skipped' || 'cancelled' => skipped,
        _ => waiting,
      };

  String get label => switch (this) {
        waiting => 'Waiting',
        inProgress => 'In Progress',
        done => 'Done',
        noShow => 'No Show',
        skipped => 'Skipped',
      };
}

class QueueItem extends Equatable {
  final String id;
  final int queueNumber;
  final String patientId;
  final String patientName;
  final int? patientAge;
  final String appointmentId;
  final String doctorId;
  final String doctorName;
  final String? room;
  final QueueStatus status;
  final int? estimatedWaitMinutes;
  final int? elapsedMinutes;
  final DateTime? checkedInAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String reason;

  const QueueItem({
    required this.id,
    required this.queueNumber,
    required this.patientId,
    required this.patientName,
    this.patientAge,
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    this.room,
    required this.status,
    this.estimatedWaitMinutes,
    this.elapsedMinutes,
    this.checkedInAt,
    this.startedAt,
    this.completedAt,
    required this.reason,
  });

  @override
  List<Object?> get props => [
        id, queueNumber, patientId, patientName, patientAge,
        appointmentId, doctorId, doctorName, room, status,
        estimatedWaitMinutes, elapsedMinutes,
        checkedInAt, startedAt, completedAt, reason,
      ];
}

class DoctorQueueStat extends Equatable {
  final String doctorId;
  final String doctorName;
  final bool inConsultation;
  final int served;
  final int remaining;

  const DoctorQueueStat({
    required this.doctorId,
    required this.doctorName,
    required this.inConsultation,
    required this.served,
    required this.remaining,
  });

  @override
  List<Object?> get props => [doctorId, doctorName, inConsultation, served, remaining];
}

class QueueStats extends Equatable {
  final int totalServed;
  final double avgConsultationMinutes;
  final double avgWaitMinutes;
  final int noShowCount;
  final List<DoctorQueueStat> doctorStats;

  const QueueStats({
    this.totalServed = 0,
    this.avgConsultationMinutes = 0,
    this.avgWaitMinutes = 0,
    this.noShowCount = 0,
    this.doctorStats = const [],
  });

  static const empty = QueueStats();

  @override
  List<Object?> get props => [
        totalServed, avgConsultationMinutes, avgWaitMinutes,
        noShowCount, doctorStats,
      ];
}
