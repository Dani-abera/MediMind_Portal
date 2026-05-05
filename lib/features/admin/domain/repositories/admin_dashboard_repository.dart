import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_dashboard_data.dart';

abstract class AdminDashboardRepository {
  Future<Either<Failure, AdminDashboardData>> getDashboardData(String centerId);
}
