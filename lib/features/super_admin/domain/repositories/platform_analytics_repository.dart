import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_dashboard_data.dart';
import '../entities/platform_analytics.dart';

abstract class PlatformAnalyticsRepository {
  Future<Either<Failure, PlatformDashboardData>> getDashboardData();
  Future<Either<Failure, PlatformAnalytics>> getAnalytics({String period = 'last30'});
}
