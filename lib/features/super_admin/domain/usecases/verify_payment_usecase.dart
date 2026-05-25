import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_center.dart';
import '../repositories/platform_centers_repository.dart';

class VerifyPaymentUseCase {
  final PlatformCentersRepository _repo;
  VerifyPaymentUseCase(this._repo);

  Future<Either<Failure, PlatformCenter>> call(String centerId) =>
      _repo.verifyPayment(centerId);
}
