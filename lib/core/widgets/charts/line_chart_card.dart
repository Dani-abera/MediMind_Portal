import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../cards/chart_card.dart';

class ChartSeries<T> {
  final String name;
  final List<T> data;
  final Color color;
  const ChartSeries({required this.name, required this.data, required this.color});
}

class LineChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ChartSeries<MapEntry<DateTime, double>>> series;
  final bool isLoading;
  final String? error;
  final List<Widget>? actions;

  const LineChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.series,
    this.isLoading = false,
    this.error,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: title,
      subtitle: subtitle,
      actions: actions,
      child: SizedBox(
        height: 220,
        child: isLoading
            ? const _ChartShimmer()
            : error != null
                ? _ErrorState(error!)
                : _Chart(series: series),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final List<ChartSeries<MapEntry<DateTime, double>>> series;
  const _Chart({required this.series});

  @override
  Widget build(BuildContext context) {
    if (series.every((s) => s.data.isEmpty)) {
      return Center(
        child: Text('No data available', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400)),
      );
    }
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      legend: series.length > 1
          ? const Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(fontSize: 11))
          : const Legend(isVisible: false),
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat('MMM d'),
        labelStyle: const TextStyle(fontSize: 10, color: AppColors.neutral500),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: const TextStyle(fontSize: 10, color: AppColors.neutral500),
        majorGridLines: const MajorGridLines(width: 0.5, color: AppColors.neutral200),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: series.map((s) => SplineSeries<MapEntry<DateTime, double>, DateTime>(
        name: s.name,
        dataSource: s.data,
        xValueMapper: (e, _) => e.key,
        yValueMapper: (e, _) => e.value,
        color: s.color,
        width: 2,
        markerSettings: const MarkerSettings(isVisible: false),
      )).toList(),
    );
  }
}

class _ChartShimmer extends StatelessWidget {
  const _ChartShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusSm,
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: AppTypography.bodySmall.copyWith(color: AppColors.danger)),
    );
  }
}
