import '../../../../core/network/dio_client.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/revenue_data.dart';
import '../models/analytics_summary_model.dart';

class AnalyticsRemoteDataSource {
  final DioClient _client;

  // In-memory 5-minute TTL cache keyed by "centerId_from_to_flags"
  final _cache = <String, ({dynamic data, DateTime fetchedAt})>{};

  AnalyticsRemoteDataSource(this._client);

  String _cacheKey(
    String centerId,
    DateTime from,
    DateTime to, [
    String extra = '',
  ]) => '${centerId}_${from.toIso8601String()}_${to.toIso8601String()}_$extra';

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
      '/healthcare-centers/$centerId/analytics',
      queryParameters: {
        'startDate': from.toIso8601String(),
        'endDate': to.toIso8601String(),
        if (comparePrevious) 'compare': 'true',
      },
    );
    final model = AnalyticsSummaryModel.fromJson(
      resp.data as Map<String, dynamic>,
    );
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
      '/healthcare-centers/$centerId/revenue',
      queryParameters: {
        'startDate': from.toIso8601String(),
        'endDate': to.toIso8601String(),
        'groupBy': groupBy.name,
        if (comparePrevious) 'compare': 'true',
      },
    );
    return RevenueSummaryModel.fromJson(
      resp.data as Map<String, dynamic>,
    );
  }

  Future<DoctorAnalyticsDetail> getDoctorAnalytics(
    String centerId,
    String doctorId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final resp = await _client.dio.get(
      '/healthcare-centers/$centerId/analytics',
      queryParameters: {
        'startDate': from.toIso8601String(),
        'endDate': to.toIso8601String(),
        'doctorId': doctorId,
      },
    );
    final d = (resp.data as Map<String, dynamic>);
    final summary = d['summary'] as Map<String, dynamic>? ?? {};
    final revenueMetrics = d['revenueMetrics'] as Map<String, dynamic>? ?? {};
    final heatmap = (d['peakHoursHeatmap'] as List?) ?? [];
    final utilization = (d['doctorUtilization'] as List?) ?? [];
    final noShowList = (d['noShowRateByDoctor'] as List?) ?? [];

    // Resolve doctor name from available sub-lists
    final utilEntry = utilization.isNotEmpty
        ? utilization.first as Map<String, dynamic>
        : null;
    final noShowEntry = noShowList.isNotEmpty
        ? noShowList.first as Map<String, dynamic>
        : null;
    final resolvedName = utilEntry?['doctorName'] as String? ??
        noShowEntry?['doctorName'] as String? ??
        '';

    final totalAppts = summary['totalAppointments'] as int? ?? 0;
    final completedCount = summary['completedCount'] as int? ?? 0;
    final completionRate =
        totalAppts > 0 ? completedCount / totalAppts * 100.0 : 0.0;

    // Aggregate heatmap into day-of-week (7) and hour-of-day (24) patterns
    final dowCounts = List<double>.filled(7, 0);
    final hourCounts = List<double>.filled(24, 0);
    for (final cell in heatmap) {
      final c = cell as Map<String, dynamic>;
      final dow = (c['dayOfWeek'] as int? ?? 1) - 1; // API is 1-based Mon
      final hour = c['hour'] as int? ?? 0;
      final count = (c['count'] as num?)?.toDouble() ?? 0;
      if (dow >= 0 && dow < 7) dowCounts[dow] += count;
      if (hour >= 0 && hour < 24) hourCounts[hour] += count;
    }

    return DoctorAnalyticsDetail(
      doctorId: doctorId,
      doctorName: resolvedName,
      totalAppointments: totalAppts,
      completionRate: completionRate,
      avgRating: 0,
      totalRevenueEtb:
          (revenueMetrics['totalRevenue'] as num?)?.toDouble() ?? 0,
      volumeTrend: ((d['patientVolumeTrends']) as List?)
              ?.map(
                (e) => TimeSeriesPointModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      dayOfWeekPattern: dowCounts,
      hourOfDayPattern: hourCounts,
      topPatients: [],
      recentReviews: [],
    );
  }

  Future<String> exportAnalyticsCsv(
    String centerId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final resp = await _client.dio.get(
      '/healthcare-centers/$centerId/analytics/export/csv',
      queryParameters: {
        'startDate': from.toIso8601String(),
        'endDate': to.toIso8601String(),
      },
    );
    final data = resp.data;
    if (data is String) return data;
    return (data as Map<String, dynamic>)['url'] as String? ?? '';
  }

  Future<String> exportAnalyticsPdf(
    String centerId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final resp = await _client.dio.get(
      '/healthcare-centers/$centerId/analytics/export/pdf',
      queryParameters: {
        'startDate': from.toIso8601String(),
        'endDate': to.toIso8601String(),
      },
    );
    final pdfData = resp.data;
    if (pdfData is String) return pdfData;
    return (pdfData as Map<String, dynamic>)['url'] as String? ?? '';
  }

  Future<String> exportRevenueCsv(
    String centerId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final resp = await _client.dio.get(
      '/healthcare-centers/$centerId/revenue/export/csv',
      queryParameters: {
        'startDate': from.toIso8601String(),
        'endDate': to.toIso8601String(),
      },
    );
    final data = resp.data;
    if (data is String) return data;
    return (data as Map<String, dynamic>)['url'] as String? ?? '';
  }
}
