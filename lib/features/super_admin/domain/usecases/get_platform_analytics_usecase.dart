import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_analytics.dart';
import '../repositories/platform_analytics_repository.dart';

class GetPlatformAnalyticsUseCase {
  final PlatformAnalyticsRepository _repo;
  GetPlatformAnalyticsUseCase(this._repo);

  Future<Either<Failure, PlatformAnalytics>> call({String period = 'last30'}) =>
      _repo.getAnalytics(period: period);
}
