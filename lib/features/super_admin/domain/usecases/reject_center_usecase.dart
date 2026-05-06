import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_centers_repository.dart';

class RejectCenterUseCase {
  final PlatformCentersRepository _repo;
  RejectCenterUseCase(this._repo);

  Future<Either<Failure, void>> call(String centerId, {required String reason}) =>
      _repo.rejectCenter(centerId, reason: reason);
}
