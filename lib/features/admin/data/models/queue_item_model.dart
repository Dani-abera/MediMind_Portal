import '../../domain/entities/queue_item.dart';

class QueueItemModel extends QueueItem {
  const QueueItemModel({
    required super.id,
    required super.queueNumber,
    required super.patientId,
    required super.patientName,
    super.patientAge,
    required super.appointmentId,
    required super.doctorId,
    required super.doctorName,
    super.room,
    required super.status,
    super.estimatedWaitMinutes,
    super.elapsedMinutes,
    super.checkedInAt,
    super.startedAt,
    super.completedAt,
    required super.reason,
  });

  factory QueueItemModel.fromJson(Map<String, dynamic> j) {
    String _s(String a, [String? b]) =>
        (j[a] ?? (b != null ? j[b] : null))?.toString() ?? '';
    return QueueItemModel(
      id: _s('id'),
      queueNumber: j['queueNumber'] as int? ?? j['queue_number'] as int? ?? 0,
      patientId: _s('patientId', 'patient_id'),
      patientName: _s('patientName', 'patient_name'),
      patientAge: j['patientAge'] as int? ?? j['patient_age'] as int?,
      appointmentId: _s('appointmentId', 'appointment_id'),
      doctorId: _s('doctorId', 'doctor_id'),
      doctorName: _s('doctorName', 'doctor_name'),
      room: j['room'] as String?,
      status: QueueStatus.fromString(j['status'] as String?),
      estimatedWaitMinutes: j['estimatedWaitMinutes'] as int? ?? j['estimated_wait_minutes'] as int?,
      elapsedMinutes: j['elapsedMinutes'] as int? ?? j['elapsed_minutes'] as int?,
      checkedInAt: DateTime.tryParse(j['checkedInAt'] as String? ?? j['checked_in_at'] as String? ?? ''),
      startedAt: DateTime.tryParse(j['startedAt'] as String? ?? j['started_at'] as String? ?? ''),
      completedAt: DateTime.tryParse(j['completedAt'] as String? ?? j['completed_at'] as String? ?? ''),
      reason: _s('reason'),
    );
  }
}

class DoctorQueueStatModel extends DoctorQueueStat {
  const DoctorQueueStatModel({
    required super.doctorId,
    required super.doctorName,
    required super.inConsultation,
    required super.served,
    required super.remaining,
  });

  factory DoctorQueueStatModel.fromJson(Map<String, dynamic> j) => DoctorQueueStatModel(
        doctorId: j['doctorId'] as String? ?? j['doctor_id'] as String? ?? '',
        doctorName: j['doctorName'] as String? ?? j['doctor_name'] as String? ?? '',
        inConsultation: j['inConsultation'] as bool? ?? j['in_consultation'] as bool? ?? false,
        served: j['served'] as int? ?? 0,
        remaining: j['remaining'] as int? ?? 0,
      );
}

QueueStats queueStatsFromItems(List<QueueItem> items) {
  final served = items.where((i) => i.status == QueueStatus.done).length;
  final noShows = items.where((i) => i.status == QueueStatus.noShow).length;

  // Build per-doctor stats
  final doctorMap = <String, Map<String, dynamic>>{};
  for (final item in items) {
    doctorMap.putIfAbsent(item.doctorId, () => {
          'name': item.doctorName,
          'inConsultation': false,
          'served': 0,
          'remaining': 0,
        });
    if (item.status == QueueStatus.inProgress) {
      doctorMap[item.doctorId]!['inConsultation'] = true;
    }
    if (item.status == QueueStatus.done) {
      doctorMap[item.doctorId]!['served'] = (doctorMap[item.doctorId]!['served'] as int) + 1;
    }
    if (item.status == QueueStatus.waiting || item.status == QueueStatus.inProgress) {
      doctorMap[item.doctorId]!['remaining'] = (doctorMap[item.doctorId]!['remaining'] as int) + 1;
    }
  }

  return QueueStats(
    totalServed: served,
    noShowCount: noShows,
    doctorStats: doctorMap.entries.map((e) => DoctorQueueStat(
          doctorId: e.key,
          doctorName: e.value['name'] as String,
          inConsultation: e.value['inConsultation'] as bool,
          served: e.value['served'] as int,
          remaining: e.value['remaining'] as int,
        )).toList(),
  );
}
