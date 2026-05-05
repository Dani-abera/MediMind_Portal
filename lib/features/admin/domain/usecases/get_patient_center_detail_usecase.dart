import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_at_center.dart';
import '../repositories/admin_patient_repository.dart';
class GetPatientCenterDetailUseCase {
  final AdminPatientRepository _repo;
  GetPatientCenterDetailUseCase(this._repo);
  Future<Either<Failure, PatientCenterDetail>> call(String centerId, String patientId) =>
      _repo.getPatientDetail(centerId, patientId);
}
