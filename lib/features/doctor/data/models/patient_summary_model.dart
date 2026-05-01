import '../../domain/entities/patient.dart';
import '../../domain/entities/patient_summary.dart';

class PatientSummaryModel extends PatientSummary {
  const PatientSummaryModel({
    required super.id,
    required super.fullName,
    super.age,
    required super.gender,
    required super.phone,
    super.firstVisit,
    super.lastVisit,
    super.totalVisits,
    super.hasChronicConditions,
    super.latestRiskScore,
    super.avatarUrl,
  });

  factory PatientSummaryModel.fromJson(Map<String, dynamic> json) => PatientSummaryModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        age: json['age'] as int?,
        gender: Gender.fromString(json['gender'] as String?),
        phone: json['phone'] as String,
        firstVisit: json['firstVisit'] != null
            ? DateTime.parse(json['firstVisit'] as String)
            : null,
        lastVisit: json['lastVisit'] != null
            ? DateTime.parse(json['lastVisit'] as String)
            : null,
        totalVisits: json['totalVisits'] as int? ?? 0,
        hasChronicConditions: json['hasChronicConditions'] as bool? ?? false,
        latestRiskScore: (json['latestRiskScore'] as num?)?.toDouble(),
        avatarUrl: json['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        if (age != null) 'age': age,
        'gender': gender.name,
        'phone': phone,
        if (firstVisit != null) 'firstVisit': firstVisit!.toIso8601String(),
        if (lastVisit != null) 'lastVisit': lastVisit!.toIso8601String(),
        'totalVisits': totalVisits,
        'hasChronicConditions': hasChronicConditions,
        if (latestRiskScore != null) 'latestRiskScore': latestRiskScore,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
}
