import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_notification.dart';

abstract class PlatformNotificationsRepository {
  Future<Either<Failure, ({List<PlatformNotification> items, int total})>> getNotifications({
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, void>> markRead(String id);
  Future<Either<Failure, void>> markAllRead();
}
