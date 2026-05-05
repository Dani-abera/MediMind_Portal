import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_queue_repository.dart';
class MarkArrivedUseCase {
  final AdminQueueRepository _repo;
  MarkArrivedUseCase(this._repo);
  Future<Either<Failure, void>> call(String queueId) => _repo.markArrived(queueId);
}
