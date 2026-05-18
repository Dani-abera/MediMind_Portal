import '../../domain/entities/audit_entry.dart';

class AuditEntryModel extends AuditEntry {
  const AuditEntryModel({
    required super.id,
    required super.timestamp,
    required super.userId,
    required super.userName,
    required super.userRole,
    required super.action,
    required super.entityType,
    required super.entityId,
    required super.ipAddress,
    super.userAgent,
    super.metadata,
  });

  factory AuditEntryModel.fromJson(Map<String, dynamic> j) => AuditEntryModel(
        id: j['logId'] as String? ?? j['id'] as String? ?? '',
        timestamp: DateTime.tryParse(j['timestamp'] as String? ?? j['createdAt'] as String? ?? '') ?? DateTime.now(),
        userId: j['userId'] as String? ?? j['user_id'] as String? ?? '',
        userName: j['userName'] as String? ?? j['user_name'] as String? ?? '',
        userRole: j['userType'] as String? ?? j['userRole'] as String? ?? j['user_role'] as String? ?? '',
        action: AuditAction.fromString(j['action'] as String?),
        entityType: j['entityType'] as String? ?? j['entity_type'] as String? ?? '',
        entityId: j['entityId'] as String? ?? j['entity_id'] as String? ?? '',
        ipAddress: j['ipAddress'] as String? ?? j['ip_address'] as String? ?? '',
        userAgent: j['userAgent'] as String? ?? j['user_agent'] as String?,
        metadata: (j['metadata'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {},
      );
}
