import '../../../../core/network/dio_client.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/revenue_data.dart';
import '../models/analytics_summary_model.dart';

class AnalyticsRemoteDataSource {
  final DioClient _client;

  // In-memory 5-minute TTL cache keyed by "centerId_from_to_flags"
  final _cache = <String, ({dynamic data, DateTime fetchedAt})>{};

  AnalyticsRemoteDataSource(this._client);

  String _cacheKey(String centerId, DateTime from, DateTime to, [String extra = '']) =>
      '${centerId}_${from.toIso8601String()}_${to.toIso8601String()}_$extra';

  T? _fromCache<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.fetchedAt).inMinutes >= 5) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T?;
  }

  Future<AnalyticsSummaryModel> getAnalyticsSummary(
    String centerId, {
    required DateTime from,
    required DateTime to,
    bool comparePrevious = false,
  }) async {
    final key = _cacheKey(centerId, from, to, comparePrevious.toString());
    final cached = _fromCache<AnalyticsSummaryModel>(key);
    if (cached != null) return cached;

    final resp = await _client.dio.get(
      '/api/v1/healthcare-centers/$centerId/analytics',
      queryParameters: {
        'startDate': from.toIso8601String(),
        'endDate': to.toIso8601String(),
        if (comparePrevious) 'compare': 'true',
      },
    );
    final model = AnalyticsSummaryModel.fromJson(resp.data['data'] as Map<String, dynamic>);
    _cache[key] = (data: model, fetchedAt: DateTime.now());
    return model;
  }

  Future<RevenueSummaryModel> getRevenueSummary(
    String centerId, {
    required DateTime from,
    required DateTime to,
    required RevenueGroupBy groupBy,
    bool comparePrevious = false,
  }) async {
    final resp = await _client.dio.get(
      '/api/v1/healthcare-centers/$centerId/revenue',
      queryParameters: {
        'startDate': from.toIso8601String(),
        'endDate': to.toIso8601String(),
        'groupBy': groupBy.name,
        if (comparePrevious) 'compare': 'true',
      },
    );
    return RevenueSummaryModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<DoctorAnalyticsDetail> getDoctorAnalytics(
    String centerId,
    String doctorId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final resp = await _client.dio.get(
      '/api/v1/healthcare-centers/$centerId/analytics',
      queryParameters: {
        'startDate': from.toIso8601String(),
        'endDate': to.toIso8601String(),
        'doctorId': doctorId,
      },
    );
    final d = resp.data['data'] as Map<String, dynamic>;
    // Parse doctor-specific detail from the filtered analytics response
    return DoctorAnalyticsDetail(
      doctorId: doctorId,
      doctorName: d['doctorName'] as String? ?? '',
      totalAppointments: d['totalAppointments'] as int? ?? 0,
      completionRate: (d['completionRate'] as num?)?.toDouble() ?? 0,
      avgRating: (d['avgRating'] as num?)?.toDouble() ?? 0,
      totalRevenueEtb: (d['totalRevenueEtb'] as num?)?.toDouble() ?? 0,
      volumeTrend: ((d['volumeTrend']) as List?)
              ?.map((e) => TimeSeriesPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dayOfWeekPattern: ((d['dayOfWeekPattern']) as List?)?.map((e) => (e as num).toDouble()).toList() ??
          List.filled(7, 0),
      hourOfDayPattern: ((d['hourOfDayPattern']) as List?)?.map((e) => (e as num).toDouble()).toList() ??
          List.filled(24, 0),
      topPatients: ((d['topPatients']) as List?)?.map((e) {
            final p = e as Map<String, dynamic>;
            return TopPatientRow(
              patientName: p['patientName'] as String? ?? '',
              visitCount: p['visitCount'] as int? ?? 0,
              totalSpentEtb: (p['totalSpentEtb'] as num?)?.toDouble() ?? 0,
              lastVisit: DateTime.tryParse(p['lastVisit'] as String? ?? '') ?? DateTime.now(),
            );
          }).toList() ??
          [],
      recentReviews: ((d['recentReviews']) as List?)?.map((e) {
            final r = e as Map<String, dynamic>;
            return DoctorReview(
              patientName: r['patientName'] as String? ?? '',
              rating: (r['rating'] as num?)?.toDouble() ?? 0,
              comment: r['comment'] as String?,
              date: DateTime.tryParse(r['date'] as String? ?? '') ?? DateTime.now(),
            );
          }).toList() ??
          [],
    );
  }

  Future<String> exportAnalyticsCsv(String centerId, {required DateTime from, required DateTime to}) async {
    final resp = await _client.dio.get(
      '/api/v1/healthcare-centers/$centerId/analytics/export/csv',
      queryParameters: {'startDate': from.toIso8601String(), 'endDate': to.toIso8601String()},
    );
    return resp.data['url'] as String? ?? '';
  }

  Future<String> exportAnalyticsPdf(String centerId, {required DateTime from, required DateTime to}) async {
    final resp = await _client.dio.get(
      '/api/v1/healthcare-centers/$centerId/analytics/export/pdf',
      queryParameters: {'startDate': from.toIso8601String(), 'endDate': to.toIso8601String()},
    );
    return resp.data['url'] as String? ?? '';
  }

  Future<String> exportRevenueCsv(String centerId, {required DateTime from, required DateTime to}) async {
    final resp = await _client.dio.get(
      '/api/v1/healthcare-centers/$centerId/revenue/export/csv',
      queryParameters: {'startDate': from.toIso8601String(), 'endDate': to.toIso8601String()},
    );
    return resp.data['url'] as String? ?? '';
  }
}
