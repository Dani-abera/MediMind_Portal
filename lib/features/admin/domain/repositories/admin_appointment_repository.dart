import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_appointment.dart';

abstract class AdminAppointmentRepository {
  Future<Either<Failure, List<AdminAppointment>>> getAppointments({
    String? status, String? doctorId, DateTime? from, DateTime? to,
    bool pendingOnly = false, String? search, int page = 1, int pageSize = 20});
  Future<Either<Failure, AdminAppointment>> getAppointmentDetail(String id);
  Future<Either<Failure, void>> approveAppointment(String id);
  Future<Either<Failure, void>> rejectAppointment(String id, {String? reason});
  Future<Either<Failure, void>> cancelAppointment(String id, {String? reason});
  Future<Either<Failure, void>> bulkApprove(List<String> ids);
}
