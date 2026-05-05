import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../cards/chart_card.dart';

class BarEntry {
  final String label;
  final double value;
  final Color? color;
  const BarEntry({required this.label, required this.value, this.color});
}

class BarChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<BarEntry> data;
  final bool horizontal;
  final bool isLoading;
  final String? error;
  final Color barColor;
  final List<Widget>? actions;
  final String? valueSuffix;

  const BarChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.data,
    this.horizontal = true,
    this.isLoading = false,
    this.error,
    this.barColor = AppColors.primary,
    this.actions,
    this.valueSuffix,
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
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : error != null
                ? Center(child: Text(error!, style: AppTypography.bodySmall.copyWith(color: AppColors.danger)))
                : _Chart(data: data, horizontal: horizontal, barColor: barColor, valueSuffix: valueSuffix),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final List<BarEntry> data;
  final bool horizontal;
  final Color barColor;
  final String? valueSuffix;
  const _Chart({required this.data, required this.horizontal, required this.barColor, this.valueSuffix});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text('No data', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400)),
      );
    }

    final catAxis = CategoryAxis(
      labelStyle: const TextStyle(fontSize: 10, color: AppColors.neutral500),
      majorGridLines: const MajorGridLines(width: 0),
      axisLine: const AxisLine(width: 0),
    );
    final numAxis = NumericAxis(
      labelStyle: const TextStyle(fontSize: 10, color: AppColors.neutral500),
      majorGridLines: const MajorGridLines(width: 0.5, color: AppColors.neutral200),
      axisLine: const AxisLine(width: 0),
      majorTickLines: const MajorTickLines(size: 0),
      labelFormat: valueSuffix != null ? '{value}$valueSuffix' : '{value}',
    );

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      isTransposed: horizontal,
      primaryXAxis: catAxis,
      primaryYAxis: numAxis,
      tooltipBehavior: TooltipBehavior(enable: true),
      series: [
        BarSeries<BarEntry, String>(
          dataSource: data,
          xValueMapper: (e, _) => e.label,
          yValueMapper: (e, _) => e.value,
          pointColorMapper: (e, _) => e.color ?? barColor,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }
}
