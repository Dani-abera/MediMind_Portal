part of 'center_settings_bloc.dart';

abstract class CenterSettingsState extends Equatable {
  const CenterSettingsState();
  @override
  List<Object?> get props => [];
}

class CenterSettingsInitial extends CenterSettingsState {
  const CenterSettingsInitial();
}

class CenterSettingsLoading extends CenterSettingsState {
  const CenterSettingsLoading();
}

class CenterSettingsLoaded extends CenterSettingsState {
  final CenterConfig config;
  const CenterSettingsLoaded(this.config);
  @override
  List<Object?> get props => [config];
}

class CenterSettingsSaving extends CenterSettingsState {
  const CenterSettingsSaving();
}

class CenterSettingsSaved extends CenterSettingsState {
  const CenterSettingsSaved();
}

class CenterSettingsError extends CenterSettingsState {
  final String message;
  const CenterSettingsError(this.message);
  @override
  List<Object?> get props => [message];
}
