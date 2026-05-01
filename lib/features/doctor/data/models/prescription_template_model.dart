import '../../domain/entities/prescription_template.dart';
import 'medication_model.dart';

class PrescriptionTemplateModel extends PrescriptionTemplate {
  const PrescriptionTemplateModel({
    required super.id,
    required super.doctorId,
    required super.name,
    super.description,
    super.diagnosis,
    required super.medications,
    super.labTests,
    super.followUpInstructions,
    super.useCount,
    super.lastUsedAt,
    required super.createdAt,
  });

  factory PrescriptionTemplateModel.fromJson(Map<String, dynamic> json) =>
      PrescriptionTemplateModel(
        id: json['id'] as String,
        doctorId: json['doctorId'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        diagnosis: json['diagnosis'] as String?,
        medications: (json['medications'] as List<dynamic>? ?? [])
            .map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        labTests: (json['labTests'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        followUpInstructions: json['followUpInstructions'] as String?,
        useCount: json['useCount'] as int? ?? 0,
        lastUsedAt: json['lastUsedAt'] != null
            ? DateTime.parse(json['lastUsedAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorId': doctorId,
        'name': name,
        if (description != null) 'description': description,
        if (diagnosis != null) 'diagnosis': diagnosis,
        'medications': medications
            .map((m) => MedicationModel.fromEntity(m).toJson())
            .toList(),
        'labTests': labTests,
        if (followUpInstructions != null) 'followUpInstructions': followUpInstructions,
        'useCount': useCount,
        if (lastUsedAt != null) 'lastUsedAt': lastUsedAt!.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}
