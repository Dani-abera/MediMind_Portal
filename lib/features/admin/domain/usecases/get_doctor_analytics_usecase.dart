import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/analytics_data.dart';
import '../repositories/analytics_repository.dart';

class GetDoctorAnalyticsUseCase {
  final AnalyticsRepository _repo;
  GetDoctorAnalyticsUseCase(this._repo);

  Future<Either<Failure, DoctorAnalyticsDetail>> call(
    String centerId,
    String doctorId, {
    required DateTime from,
    required DateTime to,
  }) =>
      _repo.getDoctorAnalytics(centerId, doctorId, from: from, to: to);
}
