import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/usecases/get_prescription_templates_usecase.dart';
import '../../../domain/repositories/prescription_repository.dart';
import '../../../domain/entities/prescription_template.dart';

part 'prescription_templates_event.dart';
part 'prescription_templates_state.dart';

class PrescriptionTemplatesBloc
    extends Bloc<PrescriptionTemplatesEvent, PrescriptionTemplatesState> {
  final GetPrescriptionTemplatesUseCase _getTemplates;
  final PrescriptionRepository _prescriptionRepo;

  PrescriptionTemplatesBloc({
    required GetPrescriptionTemplatesUseCase getTemplates,
    required PrescriptionRepository prescriptionRepo,
  })  : _getTemplates = getTemplates,
        _prescriptionRepo = prescriptionRepo,
        super(const PrescriptionTemplatesInitial()) {
    on<PrescriptionTemplatesStarted>(_onStarted, transformer: droppable());
    on<PrescriptionTemplateDeleted>(_onDeleted, transformer: droppable());
  }

  Future<void> _onStarted(
    PrescriptionTemplatesStarted event,
    Emitter<PrescriptionTemplatesState> emit,
  ) async {
    emit(const PrescriptionTemplatesLoading());
    final result = await _getTemplates();
    result.fold(
      (f) => emit(PrescriptionTemplatesError(f.message)),
      (templates) => emit(PrescriptionTemplatesLoaded(templates)),
    );
  }

  Future<void> _onDeleted(
    PrescriptionTemplateDeleted event,
    Emitter<PrescriptionTemplatesState> emit,
  ) async {
    final current = state;
    if (current is! PrescriptionTemplatesLoaded) return;
    emit(const PrescriptionTemplateDeleteInProgress());
    final result = await _prescriptionRepo.deleteTemplate(event.id);
    result.fold(
      (f) => emit(PrescriptionTemplatesError(f.message)),
      (_) {
        emit(const PrescriptionTemplateDeleteSuccess());
        final updated = current.templates.where((t) => t.id != event.id).toList();
        emit(PrescriptionTemplatesLoaded(updated));
      },
    );
  }
}
