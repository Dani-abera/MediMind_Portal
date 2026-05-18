import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/super_admin_profile.dart';

abstract class SuperAdminProfileRepository {
  Future<Either<Failure, SuperAdminProfile>> getProfile();
  Future<Either<Failure, SuperAdminProfile>> updateProfile(SuperAdminProfile profile);
}
