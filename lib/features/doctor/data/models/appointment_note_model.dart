import '../../domain/entities/appointment_note.dart';

class AppointmentNoteModel extends AppointmentNote {
  const AppointmentNoteModel({
    required super.id,
    required super.appointmentId,
    required super.doctorId,
    required super.content,
    required super.createdAt,
    super.updatedAt,
  });

  factory AppointmentNoteModel.fromJson(Map<String, dynamic> json) => AppointmentNoteModel(
        id: json['id'] as String,
        appointmentId: json['appointmentId'] as String,
        doctorId: json['doctorId'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'appointmentId': appointmentId,
        'doctorId': doctorId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}
