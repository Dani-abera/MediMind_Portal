import 'package:equatable/equatable.dart';

class AppointmentNote extends Equatable {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppointmentNote({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, appointmentId, doctorId, content, createdAt, updatedAt];
}
