import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_appointment_repository.dart';
class ApproveAppointmentUseCase {
  final AdminAppointmentRepository _repo;
  ApproveAppointmentUseCase(this._repo);
  Future<Either<Failure, void>> call(String id) => _repo.approveAppointment(id);
}
