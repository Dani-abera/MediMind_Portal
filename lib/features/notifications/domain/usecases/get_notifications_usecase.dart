import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_item.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository _repo;
  GetNotificationsUseCase(this._repo);

  Future<Either<Failure, List<NotificationItem>>> call() => _repo.getHistory();
}
