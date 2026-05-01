import '../../domain/entities/prediction.dart';

class PredictionModel extends Prediction {
  const PredictionModel({
    required super.id,
    required super.patientId,
    required super.predictedAt,
    required super.riskLevel,
    required super.riskScore,
    super.conditionProbabilities,
    super.recommendation,
    super.rawData,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    final conditionProbabilities = <String, double>{};
    final rawConditions = json['conditionProbabilities'] as Map<String, dynamic>?;
    if (rawConditions != null) {
      rawConditions.forEach((k, v) {
        conditionProbabilities[k] = (v as num).toDouble();
      });
    }

    return PredictionModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      predictedAt: DateTime.parse(json['predictedAt'] as String),
      riskLevel: RiskLevel.fromString(json['riskLevel'] as String?),
      riskScore: (json['riskScore'] as num).toDouble(),
      conditionProbabilities: conditionProbabilities,
      recommendation: json['recommendation'] as String?,
      rawData: json['rawData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'predictedAt': predictedAt.toIso8601String(),
        'riskLevel': riskLevel.name,
        'riskScore': riskScore,
        'conditionProbabilities': conditionProbabilities,
        if (recommendation != null) 'recommendation': recommendation,
        if (rawData != null) 'rawData': rawData,
      };
}
