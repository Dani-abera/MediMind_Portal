import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/consultation_repository.dart';
import '../entities/video_consultation.dart';

class InitiateConsultationUseCase {
  final ConsultationRepository _repo;
  InitiateConsultationUseCase(this._repo);
  Future<Either<Failure, VideoConsultation>> call(String appointmentId) => _repo.initiate(appointmentId);
}
