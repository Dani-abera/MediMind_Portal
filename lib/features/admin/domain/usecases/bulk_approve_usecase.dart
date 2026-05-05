import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_appointment_repository.dart';
class BulkApproveUseCase {
  final AdminAppointmentRepository _repo;
  BulkApproveUseCase(this._repo);
  Future<Either<Failure, void>> call(List<String> ids) => _repo.bulkApprove(ids);
}
