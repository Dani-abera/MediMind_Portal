import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/analytics_data.dart';
import '../entities/revenue_data.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, AnalyticsSummary>> getAnalyticsSummary(
    String centerId, {
    required DateTime from,
    required DateTime to,
    bool comparePrevious,
  });

  Future<Either<Failure, DoctorAnalyticsDetail>> getDoctorAnalytics(
    String centerId,
    String doctorId, {
    required DateTime from,
    required DateTime to,
  });

  Future<Either<Failure, RevenueSummary>> getRevenueSummary(
    String centerId, {
    required DateTime from,
    required DateTime to,
    required RevenueGroupBy groupBy,
    bool comparePrevious,
  });

  Future<Either<Failure, String>> exportAnalyticsCsv(String centerId, {
    required DateTime from,
    required DateTime to,
  });

  Future<Either<Failure, String>> exportAnalyticsPdf(String centerId, {
    required DateTime from,
    required DateTime to,
  });

  Future<Either<Failure, String>> exportRevenueCsv(String centerId, {
    required DateTime from,
    required DateTime to,
  });
}
