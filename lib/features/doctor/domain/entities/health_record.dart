import 'package:equatable/equatable.dart';

class HealthRecord extends Equatable {
  final String id;
  final String patientId;
  final DateTime recordedAt;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final double? glucoseLevel;
  final double? weight;
  final double? height;
  final int? heartRate;
  final double? temperature;
  final double? oxygenSaturation;

  const HealthRecord({
    required this.id,
    required this.patientId,
    required this.recordedAt,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.glucoseLevel,
    this.weight,
    this.height,
    this.heartRate,
    this.temperature,
    this.oxygenSaturation,
  });

  String? get bloodPressureFormatted =>
      bloodPressureSystolic != null && bloodPressureDiastolic != null
          ? '$bloodPressureSystolic/$bloodPressureDiastolic mmHg'
          : null;

  @override
  List<Object?> get props => [
        id, patientId, recordedAt, bloodPressureSystolic, bloodPressureDiastolic,
        glucoseLevel, weight, height, heartRate, temperature, oxygenSaturation,
      ];
}
