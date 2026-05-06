import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_centers_repository.dart';

class ReactivateCenterUseCase {
  final PlatformCentersRepository _repo;
  ReactivateCenterUseCase(this._repo);

  Future<Either<Failure, void>> call(String centerId) =>
      _repo.reactivateCenter(centerId);
}
