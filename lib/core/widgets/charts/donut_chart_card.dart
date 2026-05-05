import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../cards/chart_card.dart';

class DonutSlice {
  final String label;
  final double value;
  final Color color;
  const DonutSlice({required this.label, required this.value, required this.color});
}

class DonutChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<DonutSlice> slices;
  final String? centerLabel;
  final String? centerSubLabel;
  final bool isLoading;
  final String? error;
  final List<Widget>? actions;

  const DonutChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.slices,
    this.centerLabel,
    this.centerSubLabel,
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
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : error != null
                ? Center(child: Text(error!, style: AppTypography.bodySmall.copyWith(color: AppColors.danger)))
                : _Chart(slices: slices, centerLabel: centerLabel, centerSubLabel: centerSubLabel),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final List<DonutSlice> slices;
  final String? centerLabel;
  final String? centerSubLabel;
  const _Chart({required this.slices, this.centerLabel, this.centerSubLabel});

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty || slices.every((s) => s.value == 0)) {
      return Center(
        child: Text('No data', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400)),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SfCircularChart(
          legend: const Legend(
            isVisible: true,
            position: LegendPosition.right,
            textStyle: TextStyle(fontSize: 10, color: AppColors.neutral600),
            overflowMode: LegendItemOverflowMode.wrap,
          ),
          series: [
            DoughnutSeries<DonutSlice, String>(
              dataSource: slices,
              xValueMapper: (s, _) => s.label,
              yValueMapper: (s, _) => s.value,
              pointColorMapper: (s, _) => s.color,
              innerRadius: '65%',
              dataLabelSettings: const DataLabelSettings(isVisible: false),
            ),
          ],
        ),
        if (centerLabel != null)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerLabel!,
                  style: AppTypography.h2.copyWith(color: AppColors.primary, fontSize: 20)),
              if (centerSubLabel != null)
                Text(centerSubLabel!,
                    style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
            ],
          ),
      ],
    );
  }
}
