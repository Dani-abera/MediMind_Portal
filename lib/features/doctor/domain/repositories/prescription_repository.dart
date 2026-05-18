import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prescription.dart';
import '../entities/prescription_template.dart';
import '../entities/medication.dart';

class CreatePrescriptionParams {
  final String patientId;
  final String? appointmentId;
  final String diagnosis;
  final List<Medication> medications;
  final List<String> labTests;
  final String? followUpInstructions;
  final String? specialInstructions;
  final DateTime? expiresAt;

  const CreatePrescriptionParams({
    required this.patientId,
    this.appointmentId,
    required this.diagnosis,
    required this.medications,
    this.labTests = const [],
    this.followUpInstructions,
    this.specialInstructions,
    this.expiresAt,
  });
}

abstract class PrescriptionRepository {
  Future<Either<Failure, List<Prescription>>> getPrescriptions({
    String? status,
    String? patientId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, Prescription>> getPrescriptionById(String id);
  Future<Either<Failure, Prescription>> createPrescription(CreatePrescriptionParams params);
  Future<Either<Failure, String>> getPrescriptionPdfUrl(String id);
  Future<Either<Failure, void>> markDispensed(String id);
  Future<Either<Failure, void>> revoke(String id, String reason);

  Future<Either<Failure, List<PrescriptionTemplate>>> getTemplates();
  Future<Either<Failure, PrescriptionTemplate>> createTemplate(Map<String, dynamic> data);
  Future<Either<Failure, PrescriptionTemplate>> updateTemplate(String id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteTemplate(String id);
  Future<Either<Failure, Prescription>> createFromTemplate(String templateId, String? appointmentId);
}
