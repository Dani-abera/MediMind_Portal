import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/video_consultation.dart';

abstract class ConsultationRepository {
  Future<Either<Failure, VideoConsultation>> initiate(String appointmentId);
  Future<Either<Failure, VideoConsultation>> join(String consultationId);
  Future<Either<Failure, void>> end(String consultationId);
  Future<Either<Failure, VideoConsultation>> getById(String id);
  Future<Either<Failure, List<VideoConsultation>>> getActive();
  Future<Either<Failure, List<VideoConsultation>>> getToday();
  Future<Either<Failure, List<VideoConsultation>>> getPast({int page = 1, int pageSize = 20});
  Future<Either<Failure, List<Map<String, dynamic>>>> getChat(String consultationId);
  Future<Either<Failure, void>> sendMessage(String consultationId, String content);
}
