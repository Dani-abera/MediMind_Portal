import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_at_center.dart';
import '../repositories/admin_patient_repository.dart';
class GetPatientsAtCenterUseCase {
  final AdminPatientRepository _repo;
  GetPatientsAtCenterUseCase(this._repo);
  Future<Either<Failure, List<PatientAtCenter>>> call(String centerId,
      {String? search, DateTime? from, DateTime? to, int page = 1, int pageSize = 20}) =>
      _repo.getPatients(centerId, search: search, from: from, to: to, page: page, pageSize: pageSize);
}
