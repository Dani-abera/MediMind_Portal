import 'package:equatable/equatable.dart';

enum AppointmentType {
  inPerson,
  video;

  static AppointmentType fromString(String? s) => switch (s?.toLowerCase()) {
        'video' => video,
        _ => inPerson,
      };
}

enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow;

  static AppointmentStatus fromString(String? s) => switch (s?.toLowerCase()) {
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

enum PaymentStatus {
  pending,
  paid,
  failed,
  none;

  static PaymentStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'paid' => paid,
        'failed' => failed,
        'none' => none,
        _ => pending,
      };

  String get label => switch (this) {
        pending => 'Pending',
        paid => 'Paid',
        failed => 'Failed',
        none => 'None',
      };
}

enum BookingSource {
  patient,
  admin;

  static BookingSource fromString(String? s) => switch (s?.toLowerCase()) {
        'admin' => admin,
        _ => patient,
      };
}

class AppointmentStatusChange extends Equatable {
  final AppointmentStatus status;
  final DateTime timestamp;
  final String changedBy;
  final String? reason;

  const AppointmentStatusChange({
    required this.status,
    required this.timestamp,
    required this.changedBy,
    this.reason,
  });

  @override
  List<Object?> get props => [status, timestamp, changedBy, reason];
}

class AdminAppointment extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final int? patientAge;
  final String? patientPhone;
  final String doctorId;
  final String doctorName;
  final String? doctorSpecialization;
  final String centerId;
  final DateTime dateTime;
  final int durationMinutes;
  final AppointmentType type;
  final AppointmentStatus status;
  final String reason;
  final List<String> symptoms;
  final String? notes;
  final String? adminNotes;
  final PaymentStatus paymentStatus;
  final double? paymentAmount;
  final String? paymentTransactionId;
  final BookingSource bookedBy;
  final String? bookedSource;
  final DateTime bookedAt;
  final String? queueId;
  final int? queueNumber;
  final List<AppointmentStatusChange> statusHistory;

  const AdminAppointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientAge,
    this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    this.doctorSpecialization,
    required this.centerId,
    required this.dateTime,
    this.durationMinutes = 30,
    required this.type,
    required this.status,
    required this.reason,
    this.symptoms = const [],
    this.notes,
    this.adminNotes,
    this.paymentStatus = PaymentStatus.none,
    this.paymentAmount,
    this.paymentTransactionId,
    this.bookedBy = BookingSource.patient,
    this.bookedSource,
    required this.bookedAt,
    this.queueId,
    this.queueNumber,
    this.statusHistory = const [],
  });

  AdminAppointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    int? patientAge,
    String? patientPhone,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialization,
    String? centerId,
    DateTime? dateTime,
    int? durationMinutes,
    AppointmentType? type,
    AppointmentStatus? status,
    String? reason,
    List<String>? symptoms,
    String? notes,
    String? adminNotes,
    PaymentStatus? paymentStatus,
    double? paymentAmount,
    String? paymentTransactionId,
    BookingSource? bookedBy,
    String? bookedSource,
    DateTime? bookedAt,
    String? queueId,
    int? queueNumber,
    List<AppointmentStatusChange>? statusHistory,
  }) =>
      AdminAppointment(
        id: id ?? this.id,
        patientId: patientId ?? this.patientId,
        patientName: patientName ?? this.patientName,
        patientAge: patientAge ?? this.patientAge,
        patientPhone: patientPhone ?? this.patientPhone,
        doctorId: doctorId ?? this.doctorId,
        doctorName: doctorName ?? this.doctorName,
        doctorSpecialization: doctorSpecialization ?? this.doctorSpecialization,
        centerId: centerId ?? this.centerId,
        dateTime: dateTime ?? this.dateTime,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        type: type ?? this.type,
        status: status ?? this.status,
        reason: reason ?? this.reason,
        symptoms: symptoms ?? this.symptoms,
        notes: notes ?? this.notes,
        adminNotes: adminNotes ?? this.adminNotes,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        paymentAmount: paymentAmount ?? this.paymentAmount,
        paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
        bookedBy: bookedBy ?? this.bookedBy,
        bookedSource: bookedSource ?? this.bookedSource,
        bookedAt: bookedAt ?? this.bookedAt,
        queueId: queueId ?? this.queueId,
        queueNumber: queueNumber ?? this.queueNumber,
        statusHistory: statusHistory ?? this.statusHistory,
      );

  @override
  List<Object?> get props => [
        id, patientId, patientName, patientAge, patientPhone,
        doctorId, doctorName, doctorSpecialization, centerId,
        dateTime, durationMinutes, type, status, reason, symptoms,
        notes, adminNotes, paymentStatus, paymentAmount, paymentTransactionId,
        bookedBy, bookedSource, bookedAt, queueId, queueNumber, statusHistory,
      ];
}
