import 'package:equatable/equatable.dart';
import 'medication.dart';

enum PrescriptionStatus {
  active,
  dispensed,
  expired,
  revoked;

  String get label => switch (this) {
        active => 'Active',
        dispensed => 'Dispensed',
        expired => 'Expired',
        revoked => 'Revoked',
      };

  static PrescriptionStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'dispensed' => dispensed,
        'expired' => expired,
        'revoked' => revoked,
        _ => active,
      };
}

class Prescription extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String? appointmentId;
  final String diagnosis;
  final List<Medication> medications;
  final List<String> labTests;
  final String? followUpInstructions;
  final String? specialInstructions;
  final PrescriptionStatus status;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String? revokedReason;
  final String? qrCode;
  final String? pdfUrl;

  const Prescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    this.appointmentId,
    required this.diagnosis,
    required this.medications,
    this.labTests = const [],
    this.followUpInstructions,
    this.specialInstructions,
    required this.status,
    required this.issuedAt,
    required this.expiresAt,
    this.revokedReason,
    this.qrCode,
    this.pdfUrl,
  });

  @override
  List<Object?> get props => [
        id, patientId, patientName, doctorId, appointmentId, diagnosis,
        medications, labTests, followUpInstructions, specialInstructions,
        status, issuedAt, expiresAt, revokedReason, qrCode, pdfUrl,
      ];
}
