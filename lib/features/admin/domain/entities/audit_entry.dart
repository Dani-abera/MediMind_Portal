import 'package:equatable/equatable.dart';
import 'payment.dart';

enum AuditAction {
  appointmentApproved,
  appointmentRejected,
  appointmentCancelled,
  appointmentRescheduled,
  doctorAdded,
  doctorRemoved,
  doctorScheduleUpdated,
  patientRecordViewed,
  adminAdded,
  adminDeactivated,
  settingsUpdated,
  paymentMarkedResolved,
  queueCallNext,
  queueInsertEmergency,
  queueMarkNoShow,
  loginSuccess,
  centerConfigChanged,
  unknown;

  String get label => switch (this) {
    AuditAction.appointmentApproved    => 'APPOINTMENT_APPROVED',
    AuditAction.appointmentRejected    => 'APPOINTMENT_REJECTED',
    AuditAction.appointmentCancelled   => 'APPOINTMENT_CANCELLED',
    AuditAction.appointmentRescheduled => 'APPOINTMENT_RESCHEDULED',
    AuditAction.doctorAdded            => 'DOCTOR_ADDED',
    AuditAction.doctorRemoved          => 'DOCTOR_REMOVED',
    AuditAction.doctorScheduleUpdated  => 'DOCTOR_SCHEDULE_UPDATED',
    AuditAction.patientRecordViewed    => 'PATIENT_RECORD_VIEWED',
    AuditAction.adminAdded             => 'ADMIN_ADDED',
    AuditAction.adminDeactivated       => 'ADMIN_DEACTIVATED',
    AuditAction.settingsUpdated        => 'SETTINGS_UPDATED',
    AuditAction.paymentMarkedResolved  => 'PAYMENT_MARKED_RESOLVED',
    AuditAction.queueCallNext          => 'QUEUE_CALL_NEXT',
    AuditAction.queueInsertEmergency   => 'QUEUE_INSERT_EMERGENCY',
    AuditAction.queueMarkNoShow        => 'QUEUE_MARK_NO_SHOW',
    AuditAction.loginSuccess           => 'LOGIN_SUCCESS',
    AuditAction.centerConfigChanged    => 'CENTER_CONFIG_CHANGED',
    AuditAction.unknown                => 'UNKNOWN',
  };

  static AuditAction fromString(String? s) {
    for (final a in AuditAction.values) {
      if (a.label == s) return a;
    }
    return AuditAction.unknown;
  }
}

class AuditEntry extends Equatable {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String userRole;
  final AuditAction action;
  final String entityType;
  final String entityId;
  final String ipAddress;
  final String? userAgent;
  final Map<String, dynamic> metadata;

  const AuditEntry({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.ipAddress,
    this.userAgent,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [id, timestamp, userId, action, entityType, entityId];
}

class AuditLogFilters extends Equatable {
  final DateTime? from;
  final DateTime? to;
  final String? userId;
  final List<AuditAction> actions;
  final String? entityType;
  final String? searchQuery;

  const AuditLogFilters({
    this.from,
    this.to,
    this.userId,
    this.actions = const [],
    this.entityType,
    this.searchQuery,
  });

  AuditLogFilters copyWith({
    DateTime? from,
    DateTime? to,
    String? userId,
    List<AuditAction>? actions,
    String? entityType,
    String? searchQuery,
  }) =>
      AuditLogFilters(
        from: from ?? this.from,
        to: to ?? this.to,
        userId: userId ?? this.userId,
        actions: actions ?? this.actions,
        entityType: entityType ?? this.entityType,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props => [from, to, userId, actions, entityType, searchQuery];
}

class PaymentFilters extends Equatable {
  final AdminPaymentStatus? status;
  final DateTime? from;
  final DateTime? to;
  final String? method;
  final double? minAmount;
  final double? maxAmount;

  const PaymentFilters({this.status, this.from, this.to, this.method, this.minAmount, this.maxAmount});

  PaymentFilters copyWith({
    AdminPaymentStatus? status,
    DateTime? from,
    DateTime? to,
    String? method,
    double? minAmount,
    double? maxAmount,
  }) =>
      PaymentFilters(
        status: status ?? this.status,
        from: from ?? this.from,
        to: to ?? this.to,
        method: method ?? this.method,
        minAmount: minAmount ?? this.minAmount,
        maxAmount: maxAmount ?? this.maxAmount,
      );

  @override
  List<Object?> get props => [status, from, to, method, minAmount, maxAmount];
}

