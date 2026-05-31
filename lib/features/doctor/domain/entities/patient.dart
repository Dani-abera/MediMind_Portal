import 'package:equatable/equatable.dart';

enum Gender { male, female, notMentioned;
  String get label => switch (this) { male => 'Male', female => 'Female', notMentioned => 'Not Mentioned' };
  static Gender fromString(String? s) => switch (s?.toLowerCase()) {
    'male' => male, 'female' => female, 'notmentioned' => notMentioned, 'not mentioned' => notMentioned, _ => notMentioned,
  };
}

class EmergencyContact extends Equatable {
  final String name;
  final String phone;
  final String? relationship;
  const EmergencyContact({required this.name, required this.phone, this.relationship});
  @override
  List<Object?> get props => [name, phone, relationship];
}

class Patient extends Equatable {
  final String id;
  final String fullName;
  final DateTime? dateOfBirth;
  final int? age;
  final Gender gender;
  final String phone;
  final String? email;
  final String? bloodType;
  final String? address;
  final EmergencyContact? emergencyContact;
  final List<String> chronicConditions;
  final List<String> allergies;
  final List<String> currentMedications;
  final String? avatarUrl;
  final DateTime? lastVisit;
  final int totalVisits;

  const Patient({
    required this.id,
    required this.fullName,
    this.dateOfBirth,
    this.age,
    required this.gender,
    required this.phone,
    this.email,
    this.bloodType,
    this.address,
    this.emergencyContact,
    this.chronicConditions = const [],
    this.allergies = const [],
    this.currentMedications = const [],
    this.avatarUrl,
    this.lastVisit,
    this.totalVisits = 0,
  });

  @override
  List<Object?> get props => [
        id, fullName, dateOfBirth, age, gender, phone, email,
        bloodType, address, emergencyContact, chronicConditions,
        allergies, currentMedications, avatarUrl, lastVisit, totalVisits,
      ];
}
