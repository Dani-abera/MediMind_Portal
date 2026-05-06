import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_centers_repository.dart';

class ApproveCenterUseCase {
  final PlatformCentersRepository _repo;
  ApproveCenterUseCase(this._repo);

  Future<Either<Failure, void>> call(String centerId, {required DateTime trialEndDate, String? notes}) =>
      _repo.approveCenter(centerId, trialEndDate: trialEndDate, notes: notes);
}
