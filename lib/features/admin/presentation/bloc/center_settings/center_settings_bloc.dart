import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/center_config.dart';
import '../../../domain/usecases/get_center_config_usecase.dart';
import '../../../domain/usecases/save_center_config_usecase.dart';

part 'center_settings_event.dart';
part 'center_settings_state.dart';

class CenterSettingsBloc extends Bloc<CenterSettingsEvent, CenterSettingsState> {
  final GetCenterConfigUseCase _getCenterConfig;
  final SaveCenterConfigUseCase _saveCenterConfig;

  String _centerId = '';
  CenterConfig _config = const CenterConfig();

  CenterSettingsBloc({
    required GetCenterConfigUseCase getCenterConfig,
    required SaveCenterConfigUseCase saveCenterConfig,
  })  : _getCenterConfig = getCenterConfig,
        _saveCenterConfig = saveCenterConfig,
        super(const CenterSettingsInitial()) {
    on<CenterSettingsStarted>(_onStarted, transformer: droppable());
    on<CenterSettingsFieldChanged>(_onFieldChanged);
    on<CenterSettingsSubmitted>(_onSubmitted, transformer: droppable());
  }

  Future<void> _onStarted(CenterSettingsStarted event, Emitter<CenterSettingsState> emit) async {
    _centerId = event.centerId;
    emit(const CenterSettingsLoading());
    final result = await _getCenterConfig(_centerId);
    result.fold(
      (f) => emit(CenterSettingsError(f.message)),
      (config) {
        _config = config;
        emit(CenterSettingsLoaded(config));
      },
    );
  }

  void _onFieldChanged(CenterSettingsFieldChanged event, Emitter<CenterSettingsState> emit) {
    _config = _config.copyWith(
      name: event.name,
      phone: event.phone,
      email: event.email,
      city: event.city,
      region: event.region,
      fullAddress: event.fullAddress,
      latitude: event.latitude,
      longitude: event.longitude,
      specializations: event.specializations,
      services: event.services,
    );
    emit(CenterSettingsLoaded(_config));
  }

  Future<void> _onSubmitted(CenterSettingsSubmitted event, Emitter<CenterSettingsState> emit) async {
    emit(const CenterSettingsSaving());
    final result = await _saveCenterConfig(_centerId, _config);
    result.fold(
      (f) => emit(CenterSettingsError(f.message)),
      (config) {
        _config = config;
        emit(const CenterSettingsSaved());
        emit(CenterSettingsLoaded(_config));
      },
    );
  }
}
