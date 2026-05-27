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
    super.agoraAppId,
    super.agoraRtmToken,
    super.agoraRtmUserId,
  });

  factory VideoConsultationModel.fromJson(Map<String, dynamic> json) {
    final doctorInfo = json['doctorInfo'] as Map<String, dynamic>? ?? {};
    final patientInfo = json['patientInfo'] as Map<String, dynamic>? ?? {};
    return VideoConsultationModel(
      id: json['consultationId'] as String,
      appointmentId: json['appointmentId'] as String,
      doctorId: doctorInfo['userId'] as String? ?? '',
      patientId: patientInfo['userId'] as String? ?? '',
      patientName: patientInfo['fullName'] as String? ?? '',
      status: ConsultationStatus.fromString(json['status'] as String?),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'] as String)
          : null,
      signalingRoomId: json['roomId'] as String?,
      joinToken: null,
    );
  }

  Map<String, dynamic> toJson() => {
        'consultationId': id,
        'appointmentId': appointmentId,
        'doctorId': doctorId,
        'patientId': patientId,
        'patientName': patientName,
        'status': status.name,
        if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
        if (endedAt != null) 'endedAt': endedAt!.toIso8601String(),
        if (signalingRoomId != null) 'roomId': signalingRoomId,
      };
}
