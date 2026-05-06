import '../../domain/entities/booking_rules.dart';

class BookingRulesModel extends BookingRules {
  const BookingRulesModel({
    super.slotDurationMinutes,
    super.advanceBookingDays,
    super.cancellationHoursMin,
    super.autoApproveAll,
    super.autoApproveKnownPatients,
    super.reminder24h,
    super.reminder2h,
  });

  factory BookingRulesModel.fromJson(Map<String, dynamic> j) => BookingRulesModel(
        slotDurationMinutes: j['slotDurationMinutes'] as int? ?? 30,
        advanceBookingDays: j['advanceBookingDays'] as int? ?? 30,
        cancellationHoursMin: j['cancellationHoursMin'] as int? ?? 24,
        autoApproveAll: j['autoApproveAll'] as bool? ?? false,
        autoApproveKnownPatients: j['autoApproveKnownPatients'] as bool? ?? false,
        reminder24h: j['reminder24h'] as bool? ?? true,
        reminder2h: j['reminder2h'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'slotDurationMinutes': slotDurationMinutes,
        'advanceBookingDays': advanceBookingDays,
        'cancellationHoursMin': cancellationHoursMin,
        'autoApproveAll': autoApproveAll,
        'autoApproveKnownPatients': autoApproveKnownPatients,
        'reminder24h': reminder24h,
        'reminder2h': reminder2h,
      };
}
