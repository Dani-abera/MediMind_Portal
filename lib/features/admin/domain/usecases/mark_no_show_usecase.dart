import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_queue_repository.dart';
class MarkNoShowUseCase {
  final AdminQueueRepository _repo;
  MarkNoShowUseCase(this._repo);
  Future<Either<Failure, void>> call(String queueId) => _repo.markNoShow(queueId);
}
