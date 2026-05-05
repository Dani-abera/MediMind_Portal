import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_staff.dart';

abstract class AdminStaffRepository {
  Future<Either<Failure, List<AdminStaff>>> getAdmins(String centerId);
  Future<Either<Failure, void>> addAdmin({
    required String centerId, required String name,
    required String email, required String phone, required AdminRole role});
  Future<Either<Failure, void>> deactivateAdmin(String centerId, String adminId);
}
