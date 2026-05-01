import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/appointment_repository.dart';
import '../entities/appointment.dart';

class GetAppointmentsParams {
  final String? status;
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int pageSize;

  const GetAppointmentsParams({
    this.status,
    this.from,
    this.to,
    this.page = 1,
    this.pageSize = 20,
  });
}

class GetAppointmentsUseCase {
  final AppointmentRepository _repo;
  GetAppointmentsUseCase(this._repo);

  Future<Either<Failure, List<Appointment>>> call(GetAppointmentsParams params) =>
      _repo.getAppointments(
        status: params.status,
        from: params.from,
        to: params.to,
        page: params.page,
        pageSize: params.pageSize,
      );
}
