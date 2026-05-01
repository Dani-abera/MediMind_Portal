import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/usecases/create_prescription_usecase.dart';
import '../../../domain/repositories/prescription_repository.dart';
import '../../../domain/entities/prescription.dart';

part 'create_prescription_event.dart';
part 'create_prescription_state.dart';

class CreatePrescriptionBloc
    extends Bloc<CreatePrescriptionEvent, CreatePrescriptionState> {
  final CreatePrescriptionUseCase _createPrescription;
  final PrescriptionRepository _prescriptionRepo;

  CreatePrescriptionBloc({
    required CreatePrescriptionUseCase createPrescription,
    required PrescriptionRepository prescriptionRepo,
  })  : _createPrescription = createPrescription,
        _prescriptionRepo = prescriptionRepo,
        super(const CreatePrescriptionInitial()) {
    on<CreatePrescriptionSubmitted>(_onSubmitted, transformer: droppable());
    on<CreatePrescriptionFromTemplate>(_onFromTemplate, transformer: droppable());
  }

  Future<void> _onSubmitted(
    CreatePrescriptionSubmitted event,
    Emitter<CreatePrescriptionState> emit,
  ) async {
    emit(const CreatePrescriptionInProgress());
    final result = await _createPrescription(event.params);
    result.fold(
      (f) => emit(CreatePrescriptionFailure(f.message)),
      (prescription) => emit(CreatePrescriptionSuccess(prescription)),
    );
  }

  Future<void> _onFromTemplate(
    CreatePrescriptionFromTemplate event,
    Emitter<CreatePrescriptionState> emit,
  ) async {
    emit(const CreatePrescriptionInProgress());
    final result = await _prescriptionRepo.createFromTemplate(
      event.templateId,
      event.patientId,
      event.appointmentId,
    );
    result.fold(
      (f) => emit(CreatePrescriptionFailure(f.message)),
      (prescription) => emit(CreatePrescriptionSuccess(prescription)),
    );
  }
}
