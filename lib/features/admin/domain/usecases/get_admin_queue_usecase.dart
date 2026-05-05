import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/queue_item.dart';
import '../repositories/admin_queue_repository.dart';
class GetAdminQueueUseCase {
  final AdminQueueRepository _repo;
  GetAdminQueueUseCase(this._repo);
  Future<Either<Failure, List<QueueItem>>> call(String centerId) => _repo.getQueue(centerId);
}
