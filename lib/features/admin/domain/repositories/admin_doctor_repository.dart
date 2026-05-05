import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/doctor_at_center.dart';

abstract class AdminDoctorRepository {
  Future<Either<Failure, List<DoctorAtCenter>>> getDoctors(String centerId);
  Future<Either<Failure, void>> addDoctor(String centerId, String licenseNumber);
  Future<Either<Failure, void>> removeDoctor(String centerId, String doctorId);
  Future<Either<Failure, void>> configureSchedule(DoctorScheduleConfig config);
  Future<Either<Failure, DoctorScheduleConfig?>> getDoctorSchedule(String doctorId, String centerId);
  Future<Either<Failure, void>> deleteSchedule(String scheduleId);
}
