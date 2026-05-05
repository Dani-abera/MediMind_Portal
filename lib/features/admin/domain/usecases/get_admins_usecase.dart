import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_staff.dart';
import '../repositories/admin_staff_repository.dart';
class GetAdminsUseCase {
  final AdminStaffRepository _repo;
  GetAdminsUseCase(this._repo);
  Future<Either<Failure, List<AdminStaff>>> call(String centerId) => _repo.getAdmins(centerId);
}
