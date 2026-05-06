import '../../domain/entities/platform_settings.dart';

class PlatformSettingsModel extends PlatformSettings {
  const PlatformSettingsModel({
    super.trialFeeEtb,
    super.basicFeeEtb,
    super.premiumFeeEtb,
    super.maxAdvanceBookingDays,
    super.maxSlotDurationMinutes,
    super.featureFlags,
    super.maintenanceMode,
    super.maintenanceMessage,
  });

  factory PlatformSettingsModel.fromJson(Map<String, dynamic> j) => PlatformSettingsModel(
        trialFeeEtb: (j['trialFeeEtb'] as num?)?.toDouble() ?? 0,
        basicFeeEtb: (j['basicFeeEtb'] as num?)?.toDouble() ?? 0,
        premiumFeeEtb: (j['premiumFeeEtb'] as num?)?.toDouble() ?? 0,
        maxAdvanceBookingDays: j['maxAdvanceBookingDays'] as int? ?? 90,
        maxSlotDurationMinutes: j['maxSlotDurationMinutes'] as int? ?? 60,
        featureFlags: (j['featureFlags'] as Map?)
                ?.map((k, v) => MapEntry(k as String, v as bool)) ??
            {},
        maintenanceMode: j['maintenanceMode'] as bool? ?? false,
        maintenanceMessage: j['maintenanceMessage'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'trialFeeEtb': trialFeeEtb,
        'basicFeeEtb': basicFeeEtb,
        'premiumFeeEtb': premiumFeeEtb,
        'maxAdvanceBookingDays': maxAdvanceBookingDays,
        'maxSlotDurationMinutes': maxSlotDurationMinutes,
        'featureFlags': featureFlags,
        'maintenanceMode': maintenanceMode,
        'maintenanceMessage': maintenanceMessage,
      };
}
