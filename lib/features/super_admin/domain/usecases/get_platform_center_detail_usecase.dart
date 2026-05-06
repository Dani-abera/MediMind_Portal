import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_center.dart';
import '../repositories/platform_centers_repository.dart';

class GetPlatformCenterDetailUseCase {
  final PlatformCentersRepository _repo;
  GetPlatformCenterDetailUseCase(this._repo);

  Future<Either<Failure, PlatformCenter>> call(String centerId) =>
      _repo.getCenterDetail(centerId);
}
