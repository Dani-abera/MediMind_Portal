import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';
import '../entities/appointment_note.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<Appointment>>> getAppointments({
    String? status,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, Appointment>> getAppointmentById(String id);

  Future<Either<Failure, AppointmentNote>> addNote({
    required String appointmentId,
    required String content,
  });

  Future<Either<Failure, List<AppointmentNote>>> getNotes(String appointmentId);

  Future<Either<Failure, void>> cancelAppointment(String id);
  Future<Either<Failure, void>> markComplete(String id);
  Future<Either<Failure, void>> doctorRejectAppointment(String id, String reason);
}
