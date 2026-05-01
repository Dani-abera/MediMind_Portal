import '../../domain/entities/queue_entry.dart';

class QueueEntryModel extends QueueEntry {
  const QueueEntryModel({
    required super.id,
    required super.queueNumber,
    required super.patientId,
    required super.patientName,
    super.patientAge,
    required super.appointmentId,
    required super.appointmentTime,
    required super.reason,
    required super.status,
    super.startedAt,
  });

  factory QueueEntryModel.fromJson(Map<String, dynamic> json) => QueueEntryModel(
        id: json['id'] as String,
        queueNumber: json['queueNumber'] as int,
        patientId: json['patientId'] as String,
        patientName: json['patientName'] as String,
        patientAge: json['patientAge'] as int?,
        appointmentId: json['appointmentId'] as String,
        appointmentTime: DateTime.parse(json['appointmentTime'] as String),
        reason: json['reason'] as String,
        status: QueueStatus.fromString(json['status'] as String?),
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'queueNumber': queueNumber,
        'patientId': patientId,
        'patientName': patientName,
        if (patientAge != null) 'patientAge': patientAge,
        'appointmentId': appointmentId,
        'appointmentTime': appointmentTime.toIso8601String(),
        'reason': reason,
        'status': status.name,
        if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
      };
}
