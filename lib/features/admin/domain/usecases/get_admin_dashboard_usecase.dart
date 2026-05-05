import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_dashboard_data.dart';
import '../repositories/admin_dashboard_repository.dart';
class GetAdminDashboardUseCase {
  final AdminDashboardRepository _repo;
  GetAdminDashboardUseCase(this._repo);
  Future<Either<Failure, AdminDashboardData>> call(String centerId) => _repo.getDashboardData(centerId);
}
