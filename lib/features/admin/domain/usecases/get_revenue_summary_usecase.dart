import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/revenue_data.dart';
import '../repositories/analytics_repository.dart';

class GetRevenueSummaryUseCase {
  final AnalyticsRepository _repo;
  GetRevenueSummaryUseCase(this._repo);

  Future<Either<Failure, RevenueSummary>> call(
    String centerId, {
    required DateTime from,
    required DateTime to,
    RevenueGroupBy groupBy = RevenueGroupBy.day,
    bool comparePrevious = false,
  }) =>
      _repo.getRevenueSummary(centerId,
          from: from, to: to, groupBy: groupBy, comparePrevious: comparePrevious);
}
