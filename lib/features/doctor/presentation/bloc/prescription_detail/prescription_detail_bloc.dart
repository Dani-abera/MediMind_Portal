import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/repositories/prescription_repository.dart';
import '../../../domain/entities/prescription.dart';

part 'prescription_detail_event.dart';
part 'prescription_detail_state.dart';

class PrescriptionDetailBloc
    extends Bloc<PrescriptionDetailEvent, PrescriptionDetailState> {
  final PrescriptionRepository _prescriptionRepo;

  PrescriptionDetailBloc({required PrescriptionRepository prescriptionRepo})
      : _prescriptionRepo = prescriptionRepo,
        super(const PrescriptionDetailInitial()) {
    on<PrescriptionDetailStarted>(_onStarted, transformer: droppable());
    on<PrescriptionRevoked>(_onRevoked, transformer: droppable());
    on<PrescriptionMarkedDispensed>(_onMarkedDispensed, transformer: droppable());
  }

  Future<void> _onStarted(
    PrescriptionDetailStarted event,
    Emitter<PrescriptionDetailState> emit,
  ) async {
    emit(const PrescriptionDetailLoading());
    final prescriptionResult = await _prescriptionRepo.getPrescriptionById(event.id);
    if (prescriptionResult.isLeft()) {
      prescriptionResult.fold(
        (f) => emit(PrescriptionDetailError(f.message)),
        (_) {},
      );
      return;
    }
    final pdfResult = await _prescriptionRepo.getPrescriptionPdfUrl(event.id);
    prescriptionResult.fold(
      (f) => emit(PrescriptionDetailError(f.message)),
      (prescription) => emit(PrescriptionDetailLoaded(
        prescription: prescription,
        pdfUrl: pdfResult.fold((_) => null, (url) => url),
      )),
    );
  }

  Future<void> _onRevoked(
    PrescriptionRevoked event,
    Emitter<PrescriptionDetailState> emit,
  ) async {
    final current = state;
    if (current is! PrescriptionDetailLoaded) return;
    emit(const PrescriptionDetailActionInProgress());
    final result = await _prescriptionRepo.revoke(current.prescription.id, event.reason);
    result.fold(
      (f) => emit(PrescriptionDetailError(f.message)),
      (_) async {
        final refreshed = await _prescriptionRepo.getPrescriptionById(current.prescription.id);
        refreshed.fold(
          (f) => emit(PrescriptionDetailError(f.message)),
          (prescription) => emit(PrescriptionDetailActionSuccess(prescription)),
        );
      },
    );
  }

  Future<void> _onMarkedDispensed(
    PrescriptionMarkedDispensed event,
    Emitter<PrescriptionDetailState> emit,
  ) async {
    final current = state;
    if (current is! PrescriptionDetailLoaded) return;
    emit(const PrescriptionDetailActionInProgress());
    final result = await _prescriptionRepo.markDispensed(current.prescription.id);
    result.fold(
      (f) => emit(PrescriptionDetailError(f.message)),
      (_) async {
        final refreshed = await _prescriptionRepo.getPrescriptionById(current.prescription.id);
        refreshed.fold(
          (f) => emit(PrescriptionDetailError(f.message)),
          (prescription) => emit(PrescriptionDetailActionSuccess(prescription)),
        );
      },
    );
  }
}
