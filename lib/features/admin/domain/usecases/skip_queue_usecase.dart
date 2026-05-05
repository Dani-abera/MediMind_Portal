import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_queue_repository.dart';
class SkipQueueUseCase {
  final AdminQueueRepository _repo;
  SkipQueueUseCase(this._repo);
  Future<Either<Failure, void>> call(String queueId) => _repo.skip(queueId);
}
