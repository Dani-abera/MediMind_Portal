import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/appointment_repository.dart';
import '../entities/appointment.dart';

class GetAppointmentDetailUseCase {
  final AppointmentRepository _repo;
  GetAppointmentDetailUseCase(this._repo);
  Future<Either<Failure, Appointment>> call(String id) => _repo.getAppointmentById(id);
}
