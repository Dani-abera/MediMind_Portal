import '../../domain/entities/admin_appointment.dart';

class AppointmentStatusChangeModel extends AppointmentStatusChange {
  const AppointmentStatusChangeModel({
    required super.status,
    required super.timestamp,
    required super.changedBy,
    super.reason,
  });

  factory AppointmentStatusChangeModel.fromJson(Map<String, dynamic> j) =>
      AppointmentStatusChangeModel(
        status: AppointmentStatus.fromString(j['status'] as String?),
        timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.now(),
        changedBy: j['changedBy'] as String? ?? j['changed_by'] as String? ?? '',
        reason: j['reason'] as String?,
      );
}

class AdminAppointmentModel extends AdminAppointment {
  const AdminAppointmentModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    super.patientAge,
    super.patientPhone,
    required super.doctorId,
    required super.doctorName,
    super.doctorSpecialization,
    required super.centerId,
    required super.dateTime,
    super.durationMinutes,
    required super.type,
    required super.status,
    required super.reason,
    super.symptoms,
    super.notes,
    super.adminNotes,
    super.paymentStatus,
    super.paymentAmount,
    super.paymentTransactionId,
    super.bookedBy,
    super.bookedSource,
    required super.bookedAt,
    super.queueId,
    super.queueNumber,
    super.statusHistory,
  });

  factory AdminAppointmentModel.fromJson(Map<String, dynamic> j) {
    String _s(String a, [String? b]) =>
        (j[a] ?? (b != null ? j[b] : null))?.toString() ?? '';
    return AdminAppointmentModel(
      id: _s('id'),
      patientId: _s('patientId', 'patient_id'),
      patientName: _s('patientName', 'patient_name'),
      patientAge: j['patientAge'] as int? ?? j['patient_age'] as int?,
      patientPhone: j['patientPhone'] as String? ?? j['patient_phone'] as String?,
      doctorId: _s('doctorId', 'doctor_id'),
      doctorName: _s('doctorName', 'doctor_name'),
      doctorSpecialization: j['doctorSpecialization'] as String? ?? j['doctor_specialization'] as String?,
      centerId: _s('centerId', 'center_id'),
      dateTime: DateTime.tryParse(j['dateTime'] as String? ?? j['date_time'] as String? ?? '') ?? DateTime.now(),
      durationMinutes: j['durationMinutes'] as int? ?? j['duration_minutes'] as int? ?? 30,
      type: AppointmentType.fromString(j['type'] as String?),
      status: AppointmentStatus.fromString(j['status'] as String?),
      reason: _s('reason'),
      symptoms: (j['symptoms'] as List?)?.map((e) => e.toString()).toList() ?? [],
      notes: j['notes'] as String?,
      adminNotes: j['adminNotes'] as String? ?? j['admin_notes'] as String?,
      paymentStatus: PaymentStatus.fromString(j['paymentStatus'] as String? ?? j['payment_status'] as String?),
      paymentAmount: (j['paymentAmount'] ?? j['payment_amount'] as num?)?.toDouble(),
      paymentTransactionId: j['paymentTransactionId'] as String? ?? j['payment_transaction_id'] as String?,
      bookedBy: BookingSource.fromString(j['bookedBy'] as String? ?? j['booked_by'] as String?),
      bookedSource: j['bookedSource'] as String? ?? j['booked_source'] as String?,
      bookedAt: DateTime.tryParse(j['bookedAt'] as String? ?? j['booked_at'] as String? ?? '') ?? DateTime.now(),
      queueId: j['queueId'] as String? ?? j['queue_id'] as String?,
      queueNumber: j['queueNumber'] as int? ?? j['queue_number'] as int?,
      statusHistory: ((j['statusHistory'] ?? j['status_history']) as List?)
              ?.map((e) => AppointmentStatusChangeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
