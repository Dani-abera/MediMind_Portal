import 'package:equatable/equatable.dart';

enum RiskLevel {
  low,
  moderate,
  high,
  critical;

  String get label => switch (this) {
        low => 'Low Risk',
        moderate => 'Moderate Risk',
        high => 'High Risk',
        critical => 'Critical',
      };

  static RiskLevel fromScore(double score) {
    if (score < 0.3) return low;
    if (score < 0.6) return moderate;
    if (score < 0.85) return high;
    return critical;
  }

  static RiskLevel fromString(String? s) => switch (s?.toLowerCase()) {
        'low' => low,
        'moderate' => moderate,
        'high' => high,
        'critical' => critical,
        _ => low,
      };
}

class Prediction extends Equatable {
  final String id;
  final String patientId;
  final DateTime predictedAt;
  final RiskLevel riskLevel;
  final double riskScore;
  final Map<String, double> conditionProbabilities;
  final String? recommendation;
  final Map<String, dynamic>? rawData;

  const Prediction({
    required this.id,
    required this.patientId,
    required this.predictedAt,
    required this.riskLevel,
    required this.riskScore,
    this.conditionProbabilities = const {},
    this.recommendation,
    this.rawData,
  });

  @override
  List<Object?> get props => [
        id, patientId, predictedAt, riskLevel, riskScore,
        conditionProbabilities, recommendation,
      ];
}
