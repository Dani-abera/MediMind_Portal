import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/queue_item.dart';

abstract class AdminQueueRepository {
  Future<Either<Failure, List<QueueItem>>> getQueue(String centerId);
  Future<Either<Failure, QueueItem>> callNext();
  Future<Either<Failure, void>> markArrived(String queueId);
  Future<Either<Failure, void>> markComplete(String queueId);
  Future<Either<Failure, void>> markNoShow(String queueId);
  Future<Either<Failure, void>> skip(String queueId);
  Future<Either<Failure, QueueItem>> insertEmergency(String appointmentId);
  Future<Either<Failure, QueueStats>> getQueueStats(String centerId);
}
