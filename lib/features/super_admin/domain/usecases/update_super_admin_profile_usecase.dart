import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/super_admin_profile.dart';
import '../repositories/super_admin_profile_repository.dart';

class UpdateSuperAdminProfileUseCase {
  final SuperAdminProfileRepository _repo;
  UpdateSuperAdminProfileUseCase(this._repo);

  Future<Either<Failure, SuperAdminProfile>> call(SuperAdminProfile profile) =>
      _repo.updateProfile(profile);
}
