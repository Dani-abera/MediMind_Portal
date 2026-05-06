import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_center.dart';
import '../repositories/platform_centers_repository.dart';

class GetPlatformCentersUseCase {
  final PlatformCentersRepository _repo;
  GetPlatformCentersUseCase(this._repo);

  Future<Either<Failure, ({List<PlatformCenter> centers, int total})>> call({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) =>
      _repo.getCenters(status: status, page: page, pageSize: pageSize);
}
