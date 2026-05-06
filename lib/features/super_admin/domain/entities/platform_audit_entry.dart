import 'package:equatable/equatable.dart';

class PlatformAuditEntry extends Equatable {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String userRole;
  final String? centerId;
  final String? centerName;
  final String action;
  final String entityType;
  final String entityId;
  final String? ipAddress;

  const PlatformAuditEntry({
    this.id = '',
    required this.timestamp,
    this.userId = '',
    this.userName = '',
    this.userRole = '',
    this.centerId,
    this.centerName,
    this.action = '',
    this.entityType = '',
    this.entityId = '',
    this.ipAddress,
  });

  @override
  List<Object?> get props => [
        id, timestamp, userId, userName, userRole, centerId,
        centerName, action, entityType, entityId, ipAddress,
      ];
}
