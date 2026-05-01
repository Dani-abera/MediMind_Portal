import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/patient_repository.dart';
import '../entities/patient_summary.dart';

class GetPatientsParams {
  final String? search;
  final bool? hasChronicConditions;
  final int page;
  final int pageSize;
  const GetPatientsParams({this.search, this.hasChronicConditions, this.page = 1, this.pageSize = 20});
}

class GetPatientsUseCase {
  final PatientRepository _repo;
  GetPatientsUseCase(this._repo);
  Future<Either<Failure, List<PatientSummary>>> call(GetPatientsParams p) =>
      _repo.getPatients(search: p.search, hasChronicConditions: p.hasChronicConditions, page: p.page, pageSize: p.pageSize);
}
