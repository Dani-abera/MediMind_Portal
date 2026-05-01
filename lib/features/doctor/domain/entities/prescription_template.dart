import 'package:equatable/equatable.dart';
import 'medication.dart';

class PrescriptionTemplate extends Equatable {
  final String id;
  final String doctorId;
  final String name;
  final String? description;
  final String? diagnosis;
  final List<Medication> medications;
  final List<String> labTests;
  final String? followUpInstructions;
  final int useCount;
  final DateTime? lastUsedAt;
  final DateTime createdAt;

  const PrescriptionTemplate({
    required this.id,
    required this.doctorId,
    required this.name,
    this.description,
    this.diagnosis,
    required this.medications,
    this.labTests = const [],
    this.followUpInstructions,
    this.useCount = 0,
    this.lastUsedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, doctorId, name, description, diagnosis, medications,
        labTests, followUpInstructions, useCount, lastUsedAt, createdAt,
      ];
}
