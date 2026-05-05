import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_queue_repository.dart';
class MarkCompleteUseCase {
  final AdminQueueRepository _repo;
  MarkCompleteUseCase(this._repo);
  Future<Either<Failure, void>> call(String queueId) => _repo.markComplete(queueId);
}
