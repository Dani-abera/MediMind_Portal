import '../../domain/entities/health_record.dart';

class HealthRecordModel extends HealthRecord {
  const HealthRecordModel({
    required super.id,
    required super.patientId,
    required super.recordedAt,
    super.bloodPressureSystolic,
    super.bloodPressureDiastolic,
    super.glucoseLevel,
    super.weight,
    super.height,
    super.heartRate,
    super.temperature,
    super.oxygenSaturation,
  });

  factory HealthRecordModel.fromJson(
    Map<String, dynamic> json, {
    String patientId = '',
  }) =>
      HealthRecordModel(
        id: ((json['recordId'] ?? json['id']) as String?) ?? '',
        patientId: (json['patientId'] as String?) ?? patientId,
        recordedAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        bloodPressureSystolic:
            ((json['systolicBp'] ?? json['bloodPressureSystolic']) as num?)
                ?.toInt(),
        bloodPressureDiastolic:
            ((json['diastolicBp'] ?? json['bloodPressureDiastolic']) as num?)
                ?.toInt(),
        glucoseLevel: (json['glucoseLevel'] as num?)?.toDouble(),
        weight: (json['weight'] as num?)?.toDouble(),
        height: (json['height'] as num?)?.toDouble(),
        heartRate: (json['heartRate'] as num?)?.toInt(),
        temperature: (json['temperature'] as num?)?.toDouble(),
        oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'recordedAt': recordedAt.toIso8601String(),
        if (bloodPressureSystolic != null) 'bloodPressureSystolic': bloodPressureSystolic,
        if (bloodPressureDiastolic != null) 'bloodPressureDiastolic': bloodPressureDiastolic,
        if (glucoseLevel != null) 'glucoseLevel': glucoseLevel,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (heartRate != null) 'heartRate': heartRate,
        if (temperature != null) 'temperature': temperature,
        if (oxygenSaturation != null) 'oxygenSaturation': oxygenSaturation,
      };
}
