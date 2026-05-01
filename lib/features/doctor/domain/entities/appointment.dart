import 'package:equatable/equatable.dart';

enum AppointmentType { inPerson, video }

enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow;

  static AppointmentStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'pending' => pending,
        'confirmed' => confirmed,
        'inprogress' || 'in_progress' => inProgress,
        'completed' => completed,
        'cancelled' => cancelled,
        'noshow' || 'no_show' => noShow,
        _ => pending,
      };

  String get label => switch (this) {
        pending => 'Pending',
        confirmed => 'Confirmed',
        inProgress => 'In Progress',
        completed => 'Completed',
        cancelled => 'Cancelled',
        noShow => 'No Show',
      };
}

class Appointment extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final int? patientAge;
  final String? patientPhone;
  final String doctorId;
  final String centerId;
  final String centerName;
  final DateTime dateTime;
  final AppointmentType type;
  final AppointmentStatus status;
  final String reason;
  final List<String> symptoms;
  final String? notes;
  final String? videoRoomId;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientAge,
    this.patientPhone,
    required this.doctorId,
    required this.centerId,
    required this.centerName,
    required this.dateTime,
    required this.type,
    required this.status,
    required this.reason,
    this.symptoms = const [],
    this.notes,
    this.videoRoomId,
  });

  @override
  List<Object?> get props => [
        id, patientId, patientName, patientAge, patientPhone,
        doctorId, centerId, centerName, dateTime, type, status,
        reason, symptoms, notes, videoRoomId,
      ];
}
