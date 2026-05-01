import '../../domain/entities/prescription.dart';
import 'medication_model.dart';

class PrescriptionModel extends Prescription {
  const PrescriptionModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.doctorId,
    super.appointmentId,
    required super.diagnosis,
    required super.medications,
    super.labTests,
    super.followUpInstructions,
    super.specialInstructions,
    required super.status,
    required super.issuedAt,
    required super.expiresAt,
    super.revokedReason,
    super.qrCode,
    super.pdfUrl,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) => PrescriptionModel(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        patientName: json['patientName'] as String,
        doctorId: json['doctorId'] as String,
        appointmentId: json['appointmentId'] as String?,
        diagnosis: json['diagnosis'] as String,
        medications: (json['medications'] as List<dynamic>? ?? [])
            .map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        labTests: (json['labTests'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        followUpInstructions: json['followUpInstructions'] as String?,
        specialInstructions: json['specialInstructions'] as String?,
        status: PrescriptionStatus.fromString(json['status'] as String?),
        issuedAt: DateTime.parse(json['issuedAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        revokedReason: json['revokedReason'] as String?,
        qrCode: json['qrCode'] as String?,
        pdfUrl: json['pdfUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        if (appointmentId != null) 'appointmentId': appointmentId,
        'diagnosis': diagnosis,
        'medications': medications
            .map((m) => MedicationModel.fromEntity(m).toJson())
            .toList(),
        'labTests': labTests,
        if (followUpInstructions != null) 'followUpInstructions': followUpInstructions,
        if (specialInstructions != null) 'specialInstructions': specialInstructions,
        'status': status.name,
        'issuedAt': issuedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        if (revokedReason != null) 'revokedReason': revokedReason,
        if (qrCode != null) 'qrCode': qrCode,
        if (pdfUrl != null) 'pdfUrl': pdfUrl,
      };
}
