import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/usecases/get_patient_detail_usecase.dart';
import '../../../domain/repositories/patient_repository.dart';
import '../../../domain/entities/patient.dart';
import '../../../domain/entities/health_record.dart';
import '../../../domain/entities/prediction.dart';

part 'patient_detail_event.dart';
part 'patient_detail_state.dart';

class PatientDetailBloc extends Bloc<PatientDetailEvent, PatientDetailState> {
  final GetPatientDetailUseCase _getPatientDetail;
  final PatientRepository _patientRepo;

  String? _currentPatientId;

  PatientDetailBloc({
    required GetPatientDetailUseCase getPatientDetail,
    required PatientRepository patientRepo,
  })  : _getPatientDetail = getPatientDetail,
        _patientRepo = patientRepo,
        super(const PatientDetailInitial()) {
    on<PatientDetailStarted>(_onStarted, transformer: droppable());
    on<PatientDetailRefreshed>(_onRefreshed, transformer: droppable());
  }

  Future<void> _loadPatient(
    String id,
    Emitter<PatientDetailState> emit,
  ) async {
    final results = await Future.wait([
      _getPatientDetail(id),
      _patientRepo.getHealthRecords(id),
      _patientRepo.getLatestPrediction(id),
      _patientRepo.getMedicalHistory(id),
    ]);

    final patientResult = results[0];
    final recordsResult = results[1];
    final predictionResult = results[2];
    final historyResult = results[3];

    // Check for any failure
    for (final r in results) {
      final isLeft = r.fold((_) => true, (_) => false);
      if (isLeft) {
        r.fold((f) => emit(PatientDetailError(f.message)), (_) {});
        return;
      }
    }

    patientResult.fold(
      (f) => emit(PatientDetailError(f.message)),
      (patient) => recordsResult.fold(
        (f) => emit(PatientDetailError(f.message)),
        (records) => predictionResult.fold(
          (f) => emit(PatientDetailError(f.message)),
          (prediction) => historyResult.fold(
            (f) => emit(PatientDetailError(f.message)),
            (history) => emit(PatientDetailLoaded(
              patient: patient as Patient,
              records: records as List<HealthRecord>,
              latestPrediction: prediction as Prediction?,
              medicalHistory: history as Map<String, dynamic>,
            )),
          ),
        ),
      ),
    );
  }

  Future<void> _onStarted(
    PatientDetailStarted event,
    Emitter<PatientDetailState> emit,
  ) async {
    _currentPatientId = event.id;
    emit(const PatientDetailLoading());
    await _loadPatient(event.id, emit);
  }

  Future<void> _onRefreshed(
    PatientDetailRefreshed event,
    Emitter<PatientDetailState> emit,
  ) async {
    emit(const PatientDetailLoading());
    final id = _currentPatientId;
    if (id == null) return;
    await _loadPatient(id, emit);
  }
}
