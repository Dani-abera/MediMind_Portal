import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_appointment_repository.dart';
class CancelAppointmentAdminUseCase {
  final AdminAppointmentRepository _repo;
  CancelAppointmentAdminUseCase(this._repo);
  Future<Either<Failure, void>> call(String id, {String? reason}) => _repo.cancelAppointment(id, reason: reason);
}
