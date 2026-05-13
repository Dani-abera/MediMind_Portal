import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/doctor_at_center.dart';
import '../repositories/admin_doctor_repository.dart';

class InviteDoctorUseCase {
  final AdminDoctorRepository _repo;
  InviteDoctorUseCase(this._repo);

  Future<Either<Failure, void>> call(String centerId, InviteDoctorDto dto) =>
      _repo.inviteDoctor(centerId, dto);
}
