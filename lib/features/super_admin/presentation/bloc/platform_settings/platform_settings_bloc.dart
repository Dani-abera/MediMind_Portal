import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/platform_settings.dart';
import '../../../domain/usecases/get_platform_settings_usecase.dart';
import '../../../domain/usecases/save_platform_settings_usecase.dart';

part 'platform_settings_event.dart';
part 'platform_settings_state.dart';

class PlatformSettingsBloc extends Bloc<PlatformSettingsEvent, PlatformSettingsState> {
  final GetPlatformSettingsUseCase _getSettings;
  final SavePlatformSettingsUseCase _saveSettings;

  PlatformSettings _settings = const PlatformSettings();

  PlatformSettingsBloc({
    required GetPlatformSettingsUseCase getSettings,
    required SavePlatformSettingsUseCase saveSettings,
  })  : _getSettings = getSettings,
        _saveSettings = saveSettings,
        super(const PlatformSettingsInitial()) {
    on<PlatformSettingsStarted>(_onStarted, transformer: droppable());
    on<PlatformSettingsChanged>(_onChanged);
    on<PlatformSettingsSubmitted>(_onSubmitted, transformer: droppable());
  }

  Future<void> _onStarted(PlatformSettingsStarted event, Emitter<PlatformSettingsState> emit) async {
    emit(const PlatformSettingsLoading());
    final result = await _getSettings();
    result.fold(
      (f) => emit(PlatformSettingsError(f.message)),
      (settings) {
        _settings = settings;
        emit(PlatformSettingsLoaded(settings));
      },
    );
  }

  void _onChanged(PlatformSettingsChanged event, Emitter<PlatformSettingsState> emit) {
    _settings = event.settings;
    emit(PlatformSettingsLoaded(_settings));
  }

  Future<void> _onSubmitted(PlatformSettingsSubmitted event, Emitter<PlatformSettingsState> emit) async {
    emit(const PlatformSettingsSaving());
    final result = await _saveSettings(_settings);
    result.fold(
      (f) => emit(PlatformSettingsError(f.message)),
      (settings) {
        _settings = settings;
        emit(const PlatformSettingsSaved());
        emit(PlatformSettingsLoaded(_settings));
      },
    );
  }
}
