import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    super.patientAge,
    super.patientPhone,
    required super.doctorId,
    required super.centerId,
    required super.centerName,
    required super.dateTime,
    required super.type,
    required super.status,
    required super.reason,
    super.symptoms,
    super.notes,
    super.videoConsultationId,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => AppointmentModel(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        patientName: json['patientName'] as String,
        patientAge: json['patientAge'] as int?,
        patientPhone: json['patientPhone'] as String?,
        doctorId: json['doctorId'] as String,
        centerId: json['centerId'] as String,
        centerName: json['centerName'] as String,
        dateTime: DateTime.parse(
            json['dateTime'] as String? ??
            json['appointmentTime'] as String? ??
            ''),
        type: _parseType(json['type'] as String?),
        status: AppointmentStatus.fromString(json['status'] as String?),
        reason: json['reason'] as String? ?? json['reasonForVisit'] as String? ?? '',
        symptoms: json['symptoms'] is List
            ? (json['symptoms'] as List<dynamic>).map((e) => e.toString()).toList()
            : json['symptoms'] != null ? [json['symptoms'] as String] : [],
        notes: json['notes'] as String?,
        videoConsultationId: json['videoConsultationId'] as String?,
      );

  static AppointmentType _parseType(String? s) => switch (s?.toLowerCase()) {
    'video' => AppointmentType.video,
    _ => AppointmentType.inPerson,
  };

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'patientName': patientName,
        if (patientAge != null) 'patientAge': patientAge,
        if (patientPhone != null) 'patientPhone': patientPhone,
        'doctorId': doctorId,
        'centerId': centerId,
        'centerName': centerName,
        'dateTime': dateTime.toIso8601String(),
        'type': type.name,
        'status': status.name,
        'reason': reason,
        'symptoms': symptoms,
        if (notes != null) 'notes': notes,
        if (videoConsultationId != null) 'videoConsultationId': videoConsultationId,
      };
}
