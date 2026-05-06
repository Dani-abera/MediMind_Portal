import 'package:equatable/equatable.dart';

class PlatformSettings extends Equatable {
  final double trialFeeEtb;
  final double basicFeeEtb;
  final double premiumFeeEtb;
  final int maxAdvanceBookingDays;
  final int maxSlotDurationMinutes;
  final Map<String, bool> featureFlags;
  final bool maintenanceMode;
  final String maintenanceMessage;

  const PlatformSettings({
    this.trialFeeEtb = 0,
    this.basicFeeEtb = 0,
    this.premiumFeeEtb = 0,
    this.maxAdvanceBookingDays = 90,
    this.maxSlotDurationMinutes = 60,
    this.featureFlags = const {},
    this.maintenanceMode = false,
    this.maintenanceMessage = '',
  });

  PlatformSettings copyWith({
    double? trialFeeEtb,
    double? basicFeeEtb,
    double? premiumFeeEtb,
    int? maxAdvanceBookingDays,
    int? maxSlotDurationMinutes,
    Map<String, bool>? featureFlags,
    bool? maintenanceMode,
    String? maintenanceMessage,
  }) =>
      PlatformSettings(
        trialFeeEtb: trialFeeEtb ?? this.trialFeeEtb,
        basicFeeEtb: basicFeeEtb ?? this.basicFeeEtb,
        premiumFeeEtb: premiumFeeEtb ?? this.premiumFeeEtb,
        maxAdvanceBookingDays: maxAdvanceBookingDays ?? this.maxAdvanceBookingDays,
        maxSlotDurationMinutes: maxSlotDurationMinutes ?? this.maxSlotDurationMinutes,
        featureFlags: featureFlags ?? this.featureFlags,
        maintenanceMode: maintenanceMode ?? this.maintenanceMode,
        maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      );

  @override
  List<Object?> get props => [
        trialFeeEtb, basicFeeEtb, premiumFeeEtb, maxAdvanceBookingDays,
        maxSlotDurationMinutes, featureFlags, maintenanceMode, maintenanceMessage,
      ];
}
