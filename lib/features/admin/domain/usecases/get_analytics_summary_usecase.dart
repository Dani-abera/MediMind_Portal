import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/analytics_data.dart';
import '../repositories/analytics_repository.dart';

class GetAnalyticsSummaryUseCase {
  final AnalyticsRepository _repo;
  GetAnalyticsSummaryUseCase(this._repo);

  Future<Either<Failure, AnalyticsSummary>> call(
    String centerId, {
    required DateTime from,
    required DateTime to,
    bool comparePrevious = false,
  }) =>
      _repo.getAnalyticsSummary(centerId, from: from, to: to, comparePrevious: comparePrevious);
}
