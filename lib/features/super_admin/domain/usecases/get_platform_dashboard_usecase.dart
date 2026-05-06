import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_dashboard_data.dart';
import '../repositories/platform_analytics_repository.dart';

class GetPlatformDashboardUseCase {
  final PlatformAnalyticsRepository _repo;
  GetPlatformDashboardUseCase(this._repo);

  Future<Either<Failure, PlatformDashboardData>> call() =>
      _repo.getDashboardData();
}
