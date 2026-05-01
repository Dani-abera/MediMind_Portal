import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/prescription_repository.dart';
import '../entities/prescription.dart';

class GetPrescriptionsParams {
  final String? status;
  final String? patientId;
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int pageSize;
  const GetPrescriptionsParams({this.status, this.patientId, this.from, this.to, this.page = 1, this.pageSize = 20});
}

class GetPrescriptionsUseCase {
  final PrescriptionRepository _repo;
  GetPrescriptionsUseCase(this._repo);
  Future<Either<Failure, List<Prescription>>> call(GetPrescriptionsParams p) =>
      _repo.getPrescriptions(status: p.status, patientId: p.patientId, from: p.from, to: p.to, page: p.page, pageSize: p.pageSize);
}
