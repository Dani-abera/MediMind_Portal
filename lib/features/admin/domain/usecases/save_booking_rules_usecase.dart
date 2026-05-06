import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_rules.dart';
import '../repositories/center_settings_repository.dart';

class SaveBookingRulesUseCase {
  final CenterSettingsRepository _repo;
  SaveBookingRulesUseCase(this._repo);

  Future<Either<Failure, BookingRules>> call(String centerId, BookingRules rules) =>
      _repo.saveBookingRules(centerId, rules);
}
