import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_staff.dart';
import '../repositories/admin_staff_repository.dart';
class AddAdminUseCase {
  final AdminStaffRepository _repo;
  AddAdminUseCase(this._repo);
  Future<Either<Failure, void>> call({
    required String centerId, required String name,
    required String email, required String phone, required AdminRole role}) =>
      _repo.addAdmin(centerId: centerId, name: name, email: email, phone: phone, role: role);
}
