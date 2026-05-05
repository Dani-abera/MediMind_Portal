import 'package:equatable/equatable.dart';
import 'admin_appointment.dart';

enum Gender {
  male,
  female,
  other;

  static Gender? fromString(String? s) => switch (s?.toLowerCase()) {
        'male' => male,
        'female' => female,
        'other' => other,
        _ => null,
      };

  String get label => switch (this) {
        male => 'Male',
        female => 'Female',
        other => 'Other',
      };
}

class PaymentRecord extends Equatable {
  final String id;
  final double amount;
  final String status;
  final String? transactionId;
  final DateTime date;

  const PaymentRecord({
    required this.id,
    required this.amount,
    required this.status,
    this.transactionId,
    required this.date,
  });

  @override
  List<Object?> get props => [id, amount, status, transactionId, date];
}

class PrescriptionRecord extends Equatable {
  final String id;
  final DateTime date;
  final String doctorName;
  final int medicationCount;
  final String status;

  const PrescriptionRecord({
    required this.id,
    required this.date,
    required this.doctorName,
    required this.medicationCount,
    required this.status,
  });

  @override
  List<Object?> get props => [id, date, doctorName, medicationCount, status];
}

class PatientAtCenter extends Equatable {
  final String patientId;
  final String fullName;
  final int? age;
  final Gender? gender;
  final String? phone;
  final String? email;
  final DateTime? firstVisit;
  final DateTime? lastVisit;
  final int totalAppointments;
  final double totalSpentEtb;

  const PatientAtCenter({
    required this.patientId,
    required this.fullName,
    this.age,
    this.gender,
    this.phone,
    this.email,
    this.firstVisit,
    this.lastVisit,
    this.totalAppointments = 0,
    this.totalSpentEtb = 0,
  });

  @override
  List<Object?> get props => [
        patientId, fullName, age, gender, phone, email,
        firstVisit, lastVisit, totalAppointments, totalSpentEtb,
      ];
}

class PatientCenterDetail extends Equatable {
  final PatientAtCenter patient;
  final List<AdminAppointment> appointments;
  final List<PaymentRecord> payments;
  final List<PrescriptionRecord> prescriptions;

  const PatientCenterDetail({
    required this.patient,
    this.appointments = const [],
    this.payments = const [],
    this.prescriptions = const [],
  });

  @override
  List<Object?> get props => [patient, appointments, payments, prescriptions];
}
