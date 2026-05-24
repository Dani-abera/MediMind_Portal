import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_notifications_repository.dart';

class MarkAllNotificationsReadUseCase {
  final PlatformNotificationsRepository _repo;
  MarkAllNotificationsReadUseCase(this._repo);

  Future<Either<Failure, void>> call() => _repo.markAllRead();
}
