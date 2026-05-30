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
    // Build condition probabilities from individual risk fields (API returns %)
    final conditionProbabilities = <String, double>{};
    if (json['diabetesRisk'] != null) {
      conditionProbabilities['Diabetes'] =
          (json['diabetesRisk'] as num).toDouble() / 100;
    }
    if (json['hypertensionRisk'] != null) {
      conditionProbabilities['Hypertension'] =
          (json['hypertensionRisk'] as num).toDouble() / 100;
    }
    if (json['cvdRisk'] != null) {
      conditionProbabilities['Cardiovascular Disease'] =
          (json['cvdRisk'] as num).toDouble() / 100;
    }

    // Derive worst risk level from individual category strings
    final categoryOrder = ['critical', 'high', 'medium', 'moderate', 'low'];
    final categories = [
      json['diabetesCategory'],
      json['hypertensionCategory'],
      json['cvdCategory'],
      json['riskLevel'],
    ].whereType<String>().toList();
    final worstCategory = categories.isEmpty
        ? null
        : categories.reduce((a, b) =>
            categoryOrder.indexOf(a.toLowerCase()) <
                    categoryOrder.indexOf(b.toLowerCase())
                ? a
                : b);
    // Normalise "medium" → "moderate" for RiskLevel.fromString
    final riskLevelStr = worstCategory?.toLowerCase() == 'medium'
        ? 'moderate'
        : worstCategory;

    // Overall risk score: highest individual risk / 100
    final risks = [
      json['diabetesRisk'],
      json['hypertensionRisk'],
      json['cvdRisk'],
    ].whereType<num>().toList();
    final maxRisk = risks.isEmpty
        ? 0.0
        : risks.reduce((a, b) => a > b ? a : b).toDouble() / 100;
    final riskScore =
        (json['riskScore'] as num?)?.toDouble() ?? maxRisk;

    return PredictionModel(
      id: ((json['predictionId'] ?? json['id']) as String?) ?? '',
      patientId: json['patientId'] as String,
      predictedAt: DateTime.parse(
          ((json['createdAt'] ?? json['predictedAt']) as String?) ??
              DateTime.now().toIso8601String()),
      riskLevel: RiskLevel.fromString(riskLevelStr),
      riskScore: riskScore,
      conditionProbabilities: conditionProbabilities,
      recommendation:
          ((json['recommendations'] ?? json['recommendation']) as String?),
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
