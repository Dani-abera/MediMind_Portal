import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import '../../theme/app_colors.dart';

class KpiSparkline extends StatelessWidget {
  final List<double> data;
  final Color? color;
  final bool filled;

  const KpiSparkline({
    super.key,
    required this.data,
    this.color,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final c = color ?? AppColors.primary;
    return SfSparkLineChart(
      data: data,
      color: c,
      axisCrossesAt: 0,
      axisLineColor: Colors.transparent,
      trackball: const SparkChartTrackball(activationMode: SparkChartActivationMode.tap),
      marker: const SparkChartMarker(displayMode: SparkChartMarkerDisplayMode.none),
    );
  }
}

class KpiSparklineArea extends StatelessWidget {
  final List<double> data;
  final Color? color;

  const KpiSparklineArea({super.key, required this.data, this.color});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final c = color ?? AppColors.primary;
    return SfSparkAreaChart(
      data: data,
      color: c.withAlpha(40),
      borderColor: c,
      borderWidth: 1.5,
      axisCrossesAt: 0,
      axisLineColor: Colors.transparent,
    );
  }
}
