import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_appointment.dart';
import '../repositories/admin_appointment_repository.dart';
class GetPendingAppointmentsUseCase {
  final AdminAppointmentRepository _repo;
  GetPendingAppointmentsUseCase(this._repo);
  Future<Either<Failure, List<AdminAppointment>>> call({
    String? doctorId, DateTime? from, DateTime? to, int page = 1, int pageSize = 20}) =>
      _repo.getAppointments(pendingOnly: true, doctorId: doctorId, from: from, to: to, page: page, pageSize: pageSize);
}
