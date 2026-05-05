import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/patient_at_center.dart';
import '../../../domain/usecases/get_patient_center_detail_usecase.dart';

part 'patient_center_detail_event.dart';
part 'patient_center_detail_state.dart';

class PatientCenterDetailBloc extends Bloc<PatientCenterDetailEvent, PatientCenterDetailState> {
  final GetPatientCenterDetailUseCase _getDetail;
  PatientCenterDetailBloc({required GetPatientCenterDetailUseCase getDetail})
      : _getDetail = getDetail,
        super(const PatientCenterDetailInitial()) {
    on<PatientCenterDetailStarted>(_onStarted, transformer: droppable());
  }
  Future<void> _onStarted(PatientCenterDetailStarted event, Emitter<PatientCenterDetailState> emit) async {
    emit(const PatientCenterDetailLoading());
    final result = await _getDetail(event.centerId, event.patientId);
    result.fold((f) => emit(PatientCenterDetailError(f.message)), (d) => emit(PatientCenterDetailLoaded(d)));
  }
}
