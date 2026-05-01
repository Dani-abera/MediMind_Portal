import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/prescription_repository.dart';
import '../entities/prescription.dart';

class CreatePrescriptionUseCase {
  final PrescriptionRepository _repo;
  CreatePrescriptionUseCase(this._repo);
  Future<Either<Failure, Prescription>> call(CreatePrescriptionParams params) =>
      _repo.createPrescription(params);
}
