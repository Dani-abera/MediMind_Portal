import '../../domain/entities/working_hours.dart';

class DayHoursModel extends DayHours {
  const DayHoursModel({
    required super.day,
    super.isClosed,
    super.openTime,
    super.closeTime,
    super.breakStart,
    super.breakEnd,
  });

  factory DayHoursModel.fromJson(Map<String, dynamic> j) => DayHoursModel(
        day: j['day'] as String? ?? '',
        isClosed: j['isClosed'] as bool? ?? false,
        openTime: j['openTime'] as String?,
        closeTime: j['closeTime'] as String?,
        breakStart: j['breakStart'] as String?,
        breakEnd: j['breakEnd'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'isClosed': isClosed,
        'openTime': openTime,
        'closeTime': closeTime,
        'breakStart': breakStart,
        'breakEnd': breakEnd,
      };
}

class WorkingHoursModel extends WorkingHours {
  const WorkingHoursModel({super.days});

  factory WorkingHoursModel.fromJson(Map<String, dynamic> j) => WorkingHoursModel(
        days: (j['days'] as List? ?? [])
            .map((e) => DayHoursModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'days': days
            .map((d) => DayHoursModel(
                  day: d.day,
                  isClosed: d.isClosed,
                  openTime: d.openTime,
                  closeTime: d.closeTime,
                  breakStart: d.breakStart,
                  breakEnd: d.breakEnd,
                ).toJson())
            .toList(),
      };
}
