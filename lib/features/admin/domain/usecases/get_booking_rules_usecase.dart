import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_rules.dart';
import '../repositories/center_settings_repository.dart';

class GetBookingRulesUseCase {
  final CenterSettingsRepository _repo;
  GetBookingRulesUseCase(this._repo);

  Future<Either<Failure, BookingRules>> call(String centerId) =>
      _repo.getBookingRules(centerId);
}
