import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_doctor.dart';

abstract class PlatformDoctorsRepository {
  Future<Either<Failure, ({List<PlatformDoctor> doctors, int total})>> getDoctors({
    String? status,
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, PlatformDoctor>> getDoctorDetail(String doctorId);
  Future<Either<Failure, void>> verifyDoctorLicense(String doctorId, {String? notes});
  Future<Either<Failure, void>> suspendDoctor(String doctorId, {required String reason});
}
