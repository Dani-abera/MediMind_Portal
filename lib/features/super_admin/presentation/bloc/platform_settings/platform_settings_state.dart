part of 'platform_settings_bloc.dart';

abstract class PlatformSettingsState extends Equatable {
  const PlatformSettingsState();
  @override
  List<Object?> get props => [];
}

class PlatformSettingsInitial extends PlatformSettingsState {
  const PlatformSettingsInitial();
}

class PlatformSettingsLoading extends PlatformSettingsState {
  const PlatformSettingsLoading();
}

class PlatformSettingsLoaded extends PlatformSettingsState {
  final PlatformSettings settings;
  const PlatformSettingsLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}

class PlatformSettingsSaving extends PlatformSettingsState {
  const PlatformSettingsSaving();
}

class PlatformSettingsSaved extends PlatformSettingsState {
  const PlatformSettingsSaved();
}

class PlatformSettingsError extends PlatformSettingsState {
  final String message;
  const PlatformSettingsError(this.message);
  @override
  List<Object?> get props => [message];
}
