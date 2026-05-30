import 'package:equatable/equatable.dart';

enum MedicationFrequency {
  onceDaily,
  twiceDaily,
  threeTimesDaily,
  fourTimesDaily,
  everyEightHours,
  asNeeded,
  other;

  String get label => switch (this) {
        onceDaily => 'Once daily',
        twiceDaily => 'Twice daily',
        threeTimesDaily => 'Three times daily',
        fourTimesDaily => 'Four times daily',
        everyEightHours => 'Every 8 hours',
        asNeeded => 'As needed',
        other => 'Other',
      };

  static MedicationFrequency fromString(String? s) =>
      switch (s?.toLowerCase().replaceAll(' ', '_')) {
        'once_daily' || 'oncedaily' => onceDaily,
        'twice_daily' || 'twicedaily' => twiceDaily,
        'three_times_daily' || 'threetimesdaily' => threeTimesDaily,
        'four_times_daily' || 'fourtimesdaily' => fourTimesDaily,
        'every_8_hours' || 'every8hours' || 'everyeighthours' => everyEightHours,
        'as_needed' || 'asneeded' => asNeeded,
        _ => other,
      };
}

class Medication extends Equatable {
  final String name;
  final String dosage;
  final MedicationFrequency frequency;
  final String? frequencyCustomLabel;
  final String duration;
  final String? instructions;

  const Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.frequencyCustomLabel,
    required this.duration,
    this.instructions,
  });

  String get frequencyLabel => frequencyCustomLabel ?? frequency.label;

  @override
  List<Object?> get props => [name, dosage, frequency, frequencyCustomLabel, duration, instructions];
}
