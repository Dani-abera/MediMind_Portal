part of 'platform_settings_bloc.dart';

abstract class PlatformSettingsEvent extends Equatable {
  const PlatformSettingsEvent();
  @override
  List<Object?> get props => [];
}

class PlatformSettingsStarted extends PlatformSettingsEvent {
  const PlatformSettingsStarted();
}

class PlatformSettingsChanged extends PlatformSettingsEvent {
  final PlatformSettings settings;
  const PlatformSettingsChanged(this.settings);
  @override
  List<Object?> get props => [settings];
}

class PlatformSettingsSubmitted extends PlatformSettingsEvent {
  const PlatformSettingsSubmitted();
}
