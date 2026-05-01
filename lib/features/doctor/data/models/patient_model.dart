import '../../domain/entities/patient.dart';

class EmergencyContactModel extends EmergencyContact {
  const EmergencyContactModel({
    required super.name,
    required super.phone,
    super.relationship,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) =>
      EmergencyContactModel(
        name: json['name'] as String,
        phone: json['phone'] as String,
        relationship: json['relationship'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (relationship != null) 'relationship': relationship,
      };
}

class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.fullName,
    super.dateOfBirth,
    super.age,
    required super.gender,
    required super.phone,
    super.email,
    super.bloodType,
    super.address,
    super.emergencyContact,
    super.chronicConditions,
    super.allergies,
    super.currentMedications,
    super.avatarUrl,
    super.lastVisit,
    super.totalVisits,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'] as String)
            : null,
        age: json['age'] as int?,
        gender: Gender.fromString(json['gender'] as String?),
        phone: json['phone'] as String,
        email: json['email'] as String?,
        bloodType: json['bloodType'] as String?,
        address: json['address'] as String?,
        emergencyContact: json['emergencyContact'] != null
            ? EmergencyContactModel.fromJson(
                json['emergencyContact'] as Map<String, dynamic>)
            : null,
        chronicConditions: (json['chronicConditions'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        allergies: (json['allergies'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        currentMedications: (json['currentMedications'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        avatarUrl: json['avatarUrl'] as String?,
        lastVisit: json['lastVisit'] != null
            ? DateTime.parse(json['lastVisit'] as String)
            : null,
        totalVisits: json['totalVisits'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
        if (age != null) 'age': age,
        'gender': gender.name,
        'phone': phone,
        if (email != null) 'email': email,
        if (bloodType != null) 'bloodType': bloodType,
        if (address != null) 'address': address,
        if (emergencyContact != null)
          'emergencyContact': EmergencyContactModel(
            name: emergencyContact!.name,
            phone: emergencyContact!.phone,
            relationship: emergencyContact!.relationship,
          ).toJson(),
        'chronicConditions': chronicConditions,
        'allergies': allergies,
        'currentMedications': currentMedications,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (lastVisit != null) 'lastVisit': lastVisit!.toIso8601String(),
        'totalVisits': totalVisits,
      };
}
