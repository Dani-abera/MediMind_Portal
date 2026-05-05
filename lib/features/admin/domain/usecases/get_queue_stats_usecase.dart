import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/queue_item.dart';
import '../repositories/admin_queue_repository.dart';
class GetQueueStatsUseCase {
  final AdminQueueRepository _repo;
  GetQueueStatsUseCase(this._repo);
  Future<Either<Failure, QueueStats>> call(String centerId) => _repo.getQueueStats(centerId);
}
