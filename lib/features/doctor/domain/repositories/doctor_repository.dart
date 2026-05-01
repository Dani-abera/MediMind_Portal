import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/doctor_profile.dart';
import '../entities/queue_entry.dart';
import '../entities/doctor_schedule.dart';
import '../entities/center_affiliation.dart';

abstract class DoctorRepository {
  Future<Either<Failure, DoctorProfile>> getProfile();
  Future<Either<Failure, DoctorProfile>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, List<CenterAffiliation>>> getCenters();
  Future<Either<Failure, Map<String, dynamic>>> getTodaySummary();
  Future<Either<Failure, List<QueueEntry>>> getQueue(String centerId);
  Future<Either<Failure, List<DoctorSchedule>>> getSchedules();
}
