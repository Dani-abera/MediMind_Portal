import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_appointment.dart';
import '../repositories/admin_appointment_repository.dart';
class GetAllAppointmentsUseCase {
  final AdminAppointmentRepository _repo;
  GetAllAppointmentsUseCase(this._repo);
  Future<Either<Failure, List<AdminAppointment>>> call({
    String? status, String? doctorId, DateTime? from, DateTime? to,
    int page = 1, int pageSize = 20}) =>
      _repo.getAppointments(status: status, doctorId: doctorId, from: from, to: to, page: page, pageSize: pageSize);
}
