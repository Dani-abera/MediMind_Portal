import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/usecases/get_appointment_detail_usecase.dart';
import '../../../domain/usecases/save_appointment_note_usecase.dart';
import '../../../domain/repositories/appointment_repository.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/entities/appointment_note.dart';

part 'appointment_detail_event.dart';
part 'appointment_detail_state.dart';

class AppointmentDetailBloc
    extends Bloc<AppointmentDetailEvent, AppointmentDetailState> {
  final GetAppointmentDetailUseCase _getAppointmentDetail;
  final SaveAppointmentNoteUseCase _saveNote;
  final AppointmentRepository _appointmentRepo;

  AppointmentDetailBloc({
    required GetAppointmentDetailUseCase getAppointmentDetail,
    required SaveAppointmentNoteUseCase saveNote,
    required AppointmentRepository appointmentRepo,
  })  : _getAppointmentDetail = getAppointmentDetail,
        _saveNote = saveNote,
        _appointmentRepo = appointmentRepo,
        super(const AppointmentDetailInitial()) {
    on<AppointmentDetailStarted>(_onStarted, transformer: droppable());
    on<AppointmentNoteAdded>(_onNoteAdded, transformer: droppable());
    on<AppointmentCancelled>(_onCancelled, transformer: droppable());
    on<AppointmentCompleted>(_onCompleted, transformer: droppable());
  }

  Future<void> _onStarted(
    AppointmentDetailStarted event,
    Emitter<AppointmentDetailState> emit,
  ) async {
    emit(const AppointmentDetailLoading());
    final apptResult = await _getAppointmentDetail(event.id);
    if (apptResult.isLeft()) {
      apptResult.fold(
        (f) => emit(AppointmentDetailError(f.message)),
        (_) {},
      );
      return;
    }
    final notesResult = await _appointmentRepo.getNotes(event.id);
    apptResult.fold(
      (f) => emit(AppointmentDetailError(f.message)),
      (appointment) => notesResult.fold(
        (f) => emit(AppointmentDetailError(f.message)),
        (notes) => emit(AppointmentDetailLoaded(
          appointment: appointment,
          notes: notes,
        )),
      ),
    );
  }

  Future<void> _onNoteAdded(
    AppointmentNoteAdded event,
    Emitter<AppointmentDetailState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentDetailLoaded) return;
    emit(const AppointmentDetailActionInProgress());
    final result = await _saveNote(
      appointmentId: current.appointment.id,
      content: event.content,
    );
    result.fold(
      (f) => emit(AppointmentDetailError(f.message)),
      (note) => emit(AppointmentDetailLoaded(
        appointment: current.appointment,
        notes: [...current.notes, note],
      )),
    );
  }

  Future<void> _onCancelled(
    AppointmentCancelled event,
    Emitter<AppointmentDetailState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentDetailLoaded) return;
    emit(const AppointmentDetailActionInProgress());
    final result = await _appointmentRepo.cancelAppointment(current.appointment.id);
    result.fold(
      (f) => emit(AppointmentDetailError(f.message)),
      (_) async {
        final refreshed = await _getAppointmentDetail(current.appointment.id);
        refreshed.fold(
          (f) => emit(AppointmentDetailError(f.message)),
          (appointment) => emit(AppointmentDetailActionSuccess(appointment)),
        );
      },
    );
  }

  Future<void> _onCompleted(
    AppointmentCompleted event,
    Emitter<AppointmentDetailState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentDetailLoaded) return;
    emit(const AppointmentDetailActionInProgress());
    final result = await _appointmentRepo.markComplete(current.appointment.id);
    result.fold(
      (f) => emit(AppointmentDetailError(f.message)),
      (_) async {
        final refreshed = await _getAppointmentDetail(current.appointment.id);
        refreshed.fold(
          (f) => emit(AppointmentDetailError(f.message)),
          (appointment) => emit(AppointmentDetailActionSuccess(appointment)),
        );
      },
    );
  }
}
