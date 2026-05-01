import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/appointment_repository.dart';
import '../entities/appointment_note.dart';

class SaveAppointmentNoteUseCase {
  final AppointmentRepository _repo;
  SaveAppointmentNoteUseCase(this._repo);

  Future<Either<Failure, AppointmentNote>> call({
    required String appointmentId,
    required String content,
  }) => _repo.addNote(appointmentId: appointmentId, content: content);
}
