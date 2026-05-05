import '../../../../core/network/dio_client.dart';
import '../../domain/entities/audit_entry.dart';
import '../models/audit_entry_model.dart';

class AuditLogRemoteDataSource {
  final DioClient _client;
  AuditLogRemoteDataSource(this._client);

  Future<({List<AuditEntryModel> entries, int total})> getAuditLog(
    String centerId, {
    DateTime? from,
    DateTime? to,
    String? userId,
    List<AuditAction>? actions,
    String? entityType,
    String? searchQuery,
    int page = 1,
    int pageSize = 50,
  }) async {
    final resp = await _client.dio.get(
      '/api/v1/healthcare-centers/$centerId/audit-log',
      queryParameters: {
        if (from != null) 'startDate': from.toIso8601String(),
        if (to != null) 'endDate': to.toIso8601String(),
        if (userId != null) 'userId': userId,
        if (actions != null && actions.isNotEmpty)
          'action': actions.map((a) => a.label).join(','),
        if (entityType != null) 'entityType': entityType,
        if (searchQuery != null) 'q': searchQuery,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data['data'] as List? ?? [];
    final total = resp.data['total'] as int? ?? data.length;
    return (
      entries: data.map((e) => AuditEntryModel.fromJson(e as Map<String, dynamic>)).toList(),
      total: total,
    );
  }
}
