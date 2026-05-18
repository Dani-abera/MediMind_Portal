import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/super_admin_profile.dart';
import '../repositories/super_admin_profile_repository.dart';

class GetSuperAdminProfileUseCase {
  final SuperAdminProfileRepository _repo;
  GetSuperAdminProfileUseCase(this._repo);

  Future<Either<Failure, SuperAdminProfile>> call() => _repo.getProfile();
}
