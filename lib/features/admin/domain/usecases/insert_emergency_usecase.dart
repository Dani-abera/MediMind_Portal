import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/queue_item.dart';
import '../repositories/admin_queue_repository.dart';
class InsertEmergencyUseCase {
  final AdminQueueRepository _repo;
  InsertEmergencyUseCase(this._repo);
  Future<Either<Failure, QueueItem>> call(String appointmentId) => _repo.insertEmergency(appointmentId);
}
