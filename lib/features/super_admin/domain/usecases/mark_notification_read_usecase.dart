import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_notifications_repository.dart';

class MarkNotificationReadUseCase {
  final PlatformNotificationsRepository _repo;
  MarkNotificationReadUseCase(this._repo);

  Future<Either<Failure, void>> call(String id) => _repo.markRead(id);
}
