import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../cards/chart_card.dart';

class HeatmapDataPoint {
  final int x; // dayOfWeek 0=Mon
  final int y; // hour 0-23
  final int value;
  const HeatmapDataPoint({required this.x, required this.y, required this.value});
}

class HeatmapChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<HeatmapDataPoint> data;
  final bool isLoading;
  final String? error;
  final List<Widget>? actions;

  const HeatmapChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.data,
    this.isLoading = false,
    this.error,
    this.actions,
  });

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: title,
      subtitle: subtitle,
      actions: actions,
      child: isLoading
          ? const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
          : error != null
              ? SizedBox(
                  height: 180,
                  child: Center(child: Text(error!, style: AppTypography.bodySmall.copyWith(color: AppColors.danger))),
                )
              : _HeatmapGrid(data: data),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final List<HeatmapDataPoint> data;
  const _HeatmapGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No data available', style: TextStyle(color: AppColors.neutral400, fontSize: 12))),
      );
    }

    final maxVal = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    // Build a 7×24 lookup
    final lookup = <int, Map<int, int>>{};
    for (final p in data) {
      lookup.putIfAbsent(p.x, () => {})[p.y] = p.value;
    }

    // Show hours 6-22 for readability
    const startHour = 6;
    const endHour = 22;
    final hours = List.generate(endHour - startHour + 1, (i) => startHour + i);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hour labels (top)
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Row(
              children: hours.map((h) => SizedBox(
                width: 28,
                child: Text(
                  h % 3 == 0 ? '${h}h' : '',
                  style: AppTypography.caption.copyWith(color: AppColors.neutral400, fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 2),
          // Grid rows (one per day)
          ...List.generate(7, (dayIdx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      HeatmapChartCard._days[dayIdx],
                      style: AppTypography.caption.copyWith(color: AppColors.neutral500, fontSize: 10),
                    ),
                  ),
                  ...hours.map((hour) {
                    final val = lookup[dayIdx]?[hour] ?? 0;
                    final intensity = maxVal > 0 ? val / maxVal : 0.0;
                    return Container(
                      width: 26,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: _cellColor(intensity),
                        borderRadius: AppRadius.radiusSm,
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          // Legend
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 36),
              Text('Low', style: AppTypography.caption.copyWith(color: AppColors.neutral400, fontSize: 9)),
              const SizedBox(width: 4),
              ...List.generate(5, (i) => Container(
                width: 18,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: _cellColor(i / 4),
                  borderRadius: AppRadius.radiusSm,
                ),
              )),
              const SizedBox(width: 4),
              Text('High', style: AppTypography.caption.copyWith(color: AppColors.neutral400, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Color _cellColor(double intensity) {
    if (intensity == 0) return AppColors.neutral100;
    return Color.lerp(
      const Color(0xFFB2DFDB), // light teal
      AppColors.primary,
      intensity,
    )!;
  }
}
