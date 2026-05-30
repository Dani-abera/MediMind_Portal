import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_item.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationItem>>> getHistory();
  Future<Either<Failure, void>> markRead(String id);
  Future<Either<Failure, void>> markAllRead();
}
