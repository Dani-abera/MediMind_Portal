import 'package:equatable/equatable.dart';
import 'patient.dart';

class PatientSummary extends Equatable {
  final String id;
  final String fullName;
  final int? age;
  final Gender gender;
  final String phone;
  final DateTime? firstVisit;
  final DateTime? lastVisit;
  final int totalVisits;
  final bool hasChronicConditions;
  final double? latestRiskScore;
  final String? avatarUrl;

  const PatientSummary({
    required this.id,
    required this.fullName,
    this.age,
    required this.gender,
    required this.phone,
    this.firstVisit,
    this.lastVisit,
    this.totalVisits = 0,
    this.hasChronicConditions = false,
    this.latestRiskScore,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        id, fullName, age, gender, phone, firstVisit, lastVisit,
        totalVisits, hasChronicConditions, latestRiskScore, avatarUrl,
      ];
}
