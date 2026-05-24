import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_notification.dart';
import '../repositories/platform_notifications_repository.dart';

class GetPlatformNotificationsUseCase {
  final PlatformNotificationsRepository _repo;
  GetPlatformNotificationsUseCase(this._repo);

  Future<Either<Failure, ({List<PlatformNotification> items, int total})>> call({
    int page = 1,
    int pageSize = 20,
  }) =>
      _repo.getNotifications(page: page, pageSize: pageSize);
}
