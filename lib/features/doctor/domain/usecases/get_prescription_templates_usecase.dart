import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/prescription_repository.dart';
import '../entities/prescription_template.dart';

class GetPrescriptionTemplatesUseCase {
  final PrescriptionRepository _repo;
  GetPrescriptionTemplatesUseCase(this._repo);
  Future<Either<Failure, List<PrescriptionTemplate>>> call() => _repo.getTemplates();
}
