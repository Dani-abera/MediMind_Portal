import '../../domain/entities/medication.dart';

class MedicationModel extends Medication {
  const MedicationModel({
    required super.name,
    required super.dosage,
    required super.frequency,
    super.frequencyCustomLabel,
    required super.duration,
    super.instructions,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) => MedicationModel(
        name: (json['name'] as String?) ?? '',
        dosage: (json['dosage'] as String?) ?? '',
        frequency: MedicationFrequency.fromString(json['frequency'] as String?),
        frequencyCustomLabel: json['frequencyCustomLabel'] as String?,
        duration: (json['duration'] as String?) ?? '',
        instructions: json['instructions'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'frequency': frequency.name,
        if (frequencyCustomLabel != null) 'frequencyCustomLabel': frequencyCustomLabel,
        'duration': duration,
        if (instructions != null) 'instructions': instructions,
      };

  factory MedicationModel.fromEntity(Medication m) => MedicationModel(
        name: m.name,
        dosage: m.dosage,
        frequency: m.frequency,
        frequencyCustomLabel: m.frequencyCustomLabel,
        duration: m.duration,
        instructions: m.instructions,
      );
}
