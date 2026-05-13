import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_doctor_repository.dart';

class UpdateConsultationFeeUseCase {
  final AdminDoctorRepository _repo;
  UpdateConsultationFeeUseCase(this._repo);

  Future<Either<Failure, void>> call(String centerId, String doctorId, double fee) =>
      _repo.updateConsultationFee(centerId, doctorId, fee);
}
