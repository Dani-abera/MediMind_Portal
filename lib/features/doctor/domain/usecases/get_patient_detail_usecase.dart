import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/patient_repository.dart';
import '../entities/patient.dart';

class GetPatientDetailUseCase {
  final PatientRepository _repo;
  GetPatientDetailUseCase(this._repo);
  Future<Either<Failure, Patient>> call(String id) => _repo.getPatientById(id);
}
