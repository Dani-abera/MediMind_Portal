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
    String s(String key, [String? fb]) =>
        (j[key] ?? (fb != null ? j[fb] : null))?.toString() ?? '';
    final rawQn = j['queueNumber']?.toString() ?? '';
    final queueNumber =
        int.tryParse(rawQn.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return QueueItemModel(
      id: s('queueId'),
      queueNumber: queueNumber,
      patientId: s('patientId'),
      patientName: s('patientName'),
      patientAge: j['patientAge'] as int?,
      appointmentId: s('appointmentId'),
      doctorId: s('doctorId'),
      doctorName: s('doctorName'),
      room: j['roomNumber'] as String?,
      status: QueueStatus.fromString(j['status'] as String?),
      estimatedWaitMinutes: j['estimatedWaitTimeMinutes'] as int?,
      elapsedMinutes: j['elapsedMinutes'] as int?,
      checkedInAt: DateTime.tryParse(j['calledTime'] as String? ?? ''),
      startedAt: DateTime.tryParse(j['consultationStartTime'] as String? ?? ''),
      completedAt: null,
      reason: '',
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
