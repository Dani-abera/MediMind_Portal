import '../../domain/entities/video_consultation.dart';

class VideoConsultationModel extends VideoConsultation {
  const VideoConsultationModel({
    required super.id,
    required super.appointmentId,
    required super.doctorId,
    required super.patientId,
    required super.patientName,
    required super.status,
    super.startedAt,
    super.endedAt,
    super.signalingRoomId,
    super.joinToken,
  });

  factory VideoConsultationModel.fromJson(Map<String, dynamic> json) =>
      VideoConsultationModel(
        id: json['id'] as String,
        appointmentId: json['appointmentId'] as String,
        doctorId: json['doctorId'] as String,
        patientId: json['patientId'] as String,
        patientName: json['patientName'] as String,
        status: ConsultationStatus.fromString(json['status'] as String?),
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
        signalingRoomId: json['signalingRoomId'] as String?,
        joinToken: json['joinToken'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'appointmentId': appointmentId,
        'doctorId': doctorId,
        'patientId': patientId,
        'patientName': patientName,
        'status': status.name,
        if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
        if (endedAt != null) 'endedAt': endedAt!.toIso8601String(),
        if (signalingRoomId != null) 'signalingRoomId': signalingRoomId,
        if (joinToken != null) 'joinToken': joinToken,
      };
}
