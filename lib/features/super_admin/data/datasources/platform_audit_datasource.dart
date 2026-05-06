import '../../../../core/network/dio_client.dart';
import '../../domain/entities/platform_audit_entry.dart';
import '../models/platform_audit_entry_model.dart';

class PlatformAuditDatasource {
  final DioClient _client;
  PlatformAuditDatasource(this._client);

  Future<({List<PlatformAuditEntry> entries, int total})> getAuditLog({
    String? centerId,
    String? userId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 50,
  }) async {
    final resp = await _client.dio.get('/api/v1/super-admin/audit-log', queryParameters: {
      if (centerId != null) 'centerId': centerId,
      if (userId != null) 'userId': userId,
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
      'page': page,
      'pageSize': pageSize,
    });
    final data = resp.data as Map<String, dynamic>;
    final items = (data['data'] as List? ?? [])
        .map((e) => PlatformAuditEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (entries: items, total: data['total'] as int? ?? items.length);
  }

  Future<void> exportAuditLog({String? centerId}) async {
    await _client.dio.post('/api/v1/super-admin/audit-log/export', data: {
      if (centerId != null) 'centerId': centerId,
    });
  }
}
