import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/doctor_repository.dart';
import '../entities/queue_entry.dart';

class GetQueueUseCase {
  final DoctorRepository _repo;
  GetQueueUseCase(this._repo);
  Future<Either<Failure, List<QueueEntry>>> call(String centerId) => _repo.getQueue(centerId);
}
