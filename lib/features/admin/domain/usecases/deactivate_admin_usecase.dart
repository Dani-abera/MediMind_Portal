import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_staff_repository.dart';
class DeactivateAdminUseCase {
  final AdminStaffRepository _repo;
  DeactivateAdminUseCase(this._repo);
  Future<Either<Failure, void>> call(String centerId, String adminId) => _repo.deactivateAdmin(centerId, adminId);
}
