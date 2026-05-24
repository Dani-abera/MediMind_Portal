import '../../domain/entities/patient_at_center.dart';
import 'admin_appointment_model.dart';

class PaymentRecordModel extends PaymentRecord {
  const PaymentRecordModel({
    required super.id,
    required super.amount,
    required super.status,
    super.transactionId,
    required super.date,
  });

  factory PaymentRecordModel.fromJson(Map<String, dynamic> j) => PaymentRecordModel(
        id: j['id'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        status: j['status'] as String? ?? '',
        transactionId: j['transactionId'] as String? ?? j['transaction_id'] as String?,
        date: DateTime.tryParse(j['date'] as String? ?? j['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class PrescriptionRecordModel extends PrescriptionRecord {
  const PrescriptionRecordModel({
    required super.id,
    required super.date,
    required super.doctorName,
    required super.medicationCount,
    required super.status,
  });

  factory PrescriptionRecordModel.fromJson(Map<String, dynamic> j) => PrescriptionRecordModel(
        id: j['id'] as String? ?? '',
        date: DateTime.tryParse(j['date'] as String? ?? j['createdAt'] as String? ?? '') ?? DateTime.now(),
        doctorName: j['doctorName'] as String? ?? j['doctor_name'] as String? ?? '',
        medicationCount: j['medicationCount'] as int? ?? j['medication_count'] as int? ?? 0,
        status: j['status'] as String? ?? '',
      );
}

class PatientAtCenterModel extends PatientAtCenter {
  const PatientAtCenterModel({
    required super.patientId,
    required super.fullName,
    super.age,
    super.gender,
    super.phone,
    super.email,
    super.firstVisit,
    super.lastVisit,
    super.totalAppointments,
    super.totalSpentEtb,
  });

  factory PatientAtCenterModel.fromJson(Map<String, dynamic> j) => PatientAtCenterModel(
        patientId: j['patientId'] as String? ?? j['patient_id'] as String? ?? j['id'] as String? ?? '',
        fullName: j['fullName'] as String? ?? j['full_name'] as String? ?? j['name'] as String? ?? '',
        age: j['age'] as int?,
        gender: Gender.fromString(j['gender'] as String?),
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        firstVisit: DateTime.tryParse(j['firstVisit'] as String? ?? j['first_visit'] as String? ?? ''),
        lastVisit: DateTime.tryParse(j['lastVisit'] as String? ?? j['last_visit'] as String? ?? ''),
        totalAppointments: j['totalAppointments'] as int? ?? j['total_appointments'] as int? ?? 0,
        totalSpentEtb: (j['totalSpent'] ?? j['total_spent'] as num?)?.toDouble() ?? 0,
      );
}

class PatientCenterDetailModel extends PatientCenterDetail {
  const PatientCenterDetailModel({
    required super.patient,
    super.appointments,
    super.payments,
    super.prescriptions,
  });

  factory PatientCenterDetailModel.fromJson(Map<String, dynamic> j) {
    final patientJson = j['patient'] as Map<String, dynamic>? ?? j;
    return PatientCenterDetailModel(
      patient: PatientAtCenterModel.fromJson(patientJson),
      appointments: ((j['appointments'] ?? j['recentAppointments']) as List?)
              ?.map((e) => AdminAppointmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      payments: ((j['payments'] ?? j['recentPayments']) as List?)
              ?.map((e) => PaymentRecordModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      prescriptions: ((j['prescriptions'] ?? j['recentPrescriptions']) as List?)
              ?.map((e) => PrescriptionRecordModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
