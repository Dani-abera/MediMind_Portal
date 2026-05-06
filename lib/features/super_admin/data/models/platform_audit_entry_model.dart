import '../../domain/entities/platform_audit_entry.dart';

class PlatformAuditEntryModel extends PlatformAuditEntry {
  const PlatformAuditEntryModel({
    super.id,
    required super.timestamp,
    super.userId,
    super.userName,
    super.userRole,
    super.centerId,
    super.centerName,
    super.action,
    super.entityType,
    super.entityId,
    super.ipAddress,
  });

  factory PlatformAuditEntryModel.fromJson(Map<String, dynamic> j) => PlatformAuditEntryModel(
        id: j['id'] as String? ?? '',
        timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.now(),
        userId: j['userId'] as String? ?? '',
        userName: j['userName'] as String? ?? '',
        userRole: j['userRole'] as String? ?? '',
        centerId: j['centerId'] as String?,
        centerName: j['centerName'] as String?,
        action: j['action'] as String? ?? '',
        entityType: j['entityType'] as String? ?? '',
        entityId: j['entityId'] as String? ?? '',
        ipAddress: j['ipAddress'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'userId': userId,
        'userName': userName,
        'userRole': userRole,
        'centerId': centerId,
        'centerName': centerName,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'ipAddress': ipAddress,
      };
}
