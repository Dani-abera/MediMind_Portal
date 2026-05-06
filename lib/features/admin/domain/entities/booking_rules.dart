import 'package:equatable/equatable.dart';

class BookingRules extends Equatable {
  final int slotDurationMinutes;
  final int advanceBookingDays;
  final int cancellationHoursMin;
  final bool autoApproveAll;
  final bool autoApproveKnownPatients;
  final bool reminder24h;
  final bool reminder2h;

  const BookingRules({
    this.slotDurationMinutes = 30,
    this.advanceBookingDays = 30,
    this.cancellationHoursMin = 24,
    this.autoApproveAll = false,
    this.autoApproveKnownPatients = false,
    this.reminder24h = true,
    this.reminder2h = false,
  });

  BookingRules copyWith({
    int? slotDurationMinutes,
    int? advanceBookingDays,
    int? cancellationHoursMin,
    bool? autoApproveAll,
    bool? autoApproveKnownPatients,
    bool? reminder24h,
    bool? reminder2h,
  }) =>
      BookingRules(
        slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
        advanceBookingDays: advanceBookingDays ?? this.advanceBookingDays,
        cancellationHoursMin: cancellationHoursMin ?? this.cancellationHoursMin,
        autoApproveAll: autoApproveAll ?? this.autoApproveAll,
        autoApproveKnownPatients: autoApproveKnownPatients ?? this.autoApproveKnownPatients,
        reminder24h: reminder24h ?? this.reminder24h,
        reminder2h: reminder2h ?? this.reminder2h,
      );

  @override
  List<Object?> get props => [
        slotDurationMinutes,
        advanceBookingDays,
        cancellationHoursMin,
        autoApproveAll,
        autoApproveKnownPatients,
        reminder24h,
        reminder2h,
      ];
}
