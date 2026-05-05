import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_appointment_repository.dart';
class RejectAppointmentUseCase {
  final AdminAppointmentRepository _repo;
  RejectAppointmentUseCase(this._repo);
  Future<Either<Failure, void>> call(String id, {String? reason}) => _repo.rejectAppointment(id, reason: reason);
}
