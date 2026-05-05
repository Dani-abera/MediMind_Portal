import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_at_center.dart';

abstract class AdminPatientRepository {
  Future<Either<Failure, List<PatientAtCenter>>> getPatients(String centerId,
      {String? search, DateTime? from, DateTime? to, int page = 1, int pageSize = 20});
  Future<Either<Failure, PatientCenterDetail>> getPatientDetail(String centerId, String patientId);
}
