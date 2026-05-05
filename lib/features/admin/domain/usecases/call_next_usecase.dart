import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/queue_item.dart';
import '../repositories/admin_queue_repository.dart';
class CallNextUseCase {
  final AdminQueueRepository _repo;
  CallNextUseCase(this._repo);
  Future<Either<Failure, QueueItem>> call() => _repo.callNext();
}
