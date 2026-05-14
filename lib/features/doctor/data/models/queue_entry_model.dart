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

  factory QueueEntryModel.fromJson(Map<String, dynamic> json) {
    final rawQn = json['queueNumber']?.toString() ?? '';
    final queueNumber =
        int.tryParse(rawQn.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final timeStr = json['appointmentTime'] as String? ?? '00:00:00';
    final appointmentTime =
        DateTime.tryParse('2000-01-01T$timeStr') ?? DateTime.now();
    return QueueEntryModel(
      id: rawQn.isNotEmpty ? rawQn : 'Q${queueNumber.toString().padLeft(3, '0')}',
      queueNumber: queueNumber,
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      patientAge: json['patientAge'] as int?,
      appointmentId: json['appointmentId'] as String? ?? '',
      appointmentTime: appointmentTime,
      reason: '',
      status: QueueStatus.fromString(json['status'] as String?),
      startedAt: null,
    );
  }

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
