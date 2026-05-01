import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient.dart';
import '../entities/patient_summary.dart';
import '../entities/health_record.dart';
import '../entities/prediction.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<PatientSummary>>> getPatients({
    String? search,
    bool? hasChronicConditions,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, Patient>> getPatientById(String id);
  Future<Either<Failure, List<HealthRecord>>> getHealthRecords(String patientId);
  Future<Either<Failure, Prediction?>> getLatestPrediction(String patientId);
  Future<Either<Failure, List<Prediction>>> getPredictions(String patientId);
  Future<Either<Failure, Map<String, dynamic>>> getMedicalHistory(String patientId);
}
