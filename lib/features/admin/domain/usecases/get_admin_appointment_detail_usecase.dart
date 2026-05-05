import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_appointment.dart';
import '../repositories/admin_appointment_repository.dart';
class GetAdminAppointmentDetailUseCase {
  final AdminAppointmentRepository _repo;
  GetAdminAppointmentDetailUseCase(this._repo);
  Future<Either<Failure, AdminAppointment>> call(String id) => _repo.getAppointmentDetail(id);
}
