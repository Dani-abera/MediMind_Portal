import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_centers_repository.dart';

class SuspendCenterUseCase {
  final PlatformCentersRepository _repo;
  SuspendCenterUseCase(this._repo);

  Future<Either<Failure, void>> call(String centerId, {required String reason, DateTime? suspendUntil}) =>
      _repo.suspendCenter(centerId, reason: reason, suspendUntil: suspendUntil);
}
