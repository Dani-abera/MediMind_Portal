import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/user_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cards/kpi_card.dart';
import '../../../../core/widgets/charts/bar_chart_card.dart';
import '../../../../core/widgets/charts/donut_chart_card.dart';
import '../../../../core/widgets/charts/heatmap_chart_card.dart';
import '../../../../core/widgets/charts/kpi_sparkline.dart';
import '../../../../core/widgets/charts/line_chart_card.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../domain/entities/analytics_data.dart';
import '../domain/usecases/export_analytics_usecase.dart';
import '../presentation/bloc/analytics/analytics_dashboard_bloc.dart';

class AnalyticsDashboardPage extends StatelessWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnalyticsDashboardBloc>()
        ..add(AnalyticsDashboardStarted(UserContext().centerId ?? '')),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView();
  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> {
  DateRangePreset _preset = DateRangePreset.last30;
  bool _compare = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnalyticsDashboardBloc, AnalyticsDashboardState>(
      listener: (ctx, state) {
        if (state is AnalyticsExportDone) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Export ready')));
        }
        if (state is AnalyticsExportError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Analytics',
            subtitle: 'Center performance overview',
            actions: [
              _DateRangeBar(
                selected: _preset,
                compare: _compare,
                onPresetChanged: (p) {
                  setState(() => _preset = p);
                  context.read<AnalyticsDashboardBloc>().add(AnalyticsDateRangeChanged(p));
                },
                onCompareToggled: (v) {
                  setState(() => _compare = v);
                  context.read<AnalyticsDashboardBloc>().add(AnalyticsComparePeriodToggled(v));
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              _ExportButton(),
            ],
          ),
          Expanded(
            child: BlocBuilder<AnalyticsDashboardBloc, AnalyticsDashboardState>(
              builder: (ctx, state) {
                if (state is AnalyticsDashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AnalyticsDashboardError) {
                  return Center(child: Text(state.message, style: AppTypography.body.copyWith(color: AppColors.danger)));
                }
                if (state is AnalyticsDashboardLoaded) {
                  return _Dashboard(data: state.data, range: state.range);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  final AnalyticsSummary data;
  final DateRangeSelection range;
  const _Dashboard({required this.data, required this.range});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1 — KPI cards
          _KpiRow(data: data),
          const SizedBox(height: AppSpacing.xl),
          // Row 2 — Volume trend + Status donut
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _VolumeTrendCard(data: data, range: range),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                flex: 4,
                child: _StatusDonutCard(data: data),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Row 3 — Heatmap
          HeatmapChartCard(
            title: 'Peak Hours',
            subtitle: 'Appointment volume by day and hour',
            data: data.peakHours
                .map((c) => HeatmapDataPoint(x: c.dayOfWeek, y: c.hour, value: c.value))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Row 4 — No-show by doctor + Utilization
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BarChartCard(
                  title: 'No-Show Rate by Doctor',
                  subtitle: 'Top 10, descending',
                  data: data.doctorStats
                      .sorted((a, b) => b.noShowRate.compareTo(a.noShowRate))
                      .take(10)
                      .map((d) => BarEntry(
                            label: d.doctorName,
                            value: d.noShowRate,
                            color: AppColors.danger,
                          ))
                      .toList(),
                  horizontal: true,
                  valueSuffix: '%',
                  barColor: AppColors.danger,
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: BarChartCard(
                  title: 'Doctor Utilization',
                  subtitle: 'Slots used %',
                  data: data.doctorStats
                      .map((d) => BarEntry(label: d.doctorName, value: d.utilizationPercent))
                      .toList(),
                  horizontal: true,
                  valueSuffix: '%',
                  barColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Row 5 — Revenue per doctor + Avg wait time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: BarChartCard(
                  title: 'Revenue per Doctor',
                  subtitle: 'ETB in selected period',
                  data: data.doctorStats
                      .map((d) => BarEntry(label: d.doctorName, value: d.revenueEtb))
                      .toList(),
                  horizontal: false,
                  barColor: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                flex: 4,
                child: LineChartCard(
                  title: 'Avg Wait Time Trend',
                  subtitle: 'Minutes',
                  series: [
                    ChartSeries(
                      name: 'Avg Wait (min)',
                      data: data.avgWaitTimeTrend
                          .map((p) => MapEntry(p.date, p.value))
                          .toList(),
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final AnalyticsSummary data;
  const _KpiRow({required this.data});

  String _pctChange(num? prev, num current) {
    if (prev == null || prev == 0) return '';
    final pct = ((current - prev) / prev * 100).toStringAsFixed(1);
    return '$pct%';
  }

  TrendDirection _dir(num? prev, num current) {
    if (prev == null) return TrendDirection.neutral;
    return current >= prev ? TrendDirection.up : TrendDirection.down;
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat('#,###');
    final etb = NumberFormat('#,###.0');
    return Wrap(
      spacing: AppSpacing.base,
      runSpacing: AppSpacing.base,
      children: [
        SizedBox(
          width: 200,
          child: KPICard(
            icon: FontAwesomeIcons.calendarCheck,
            title: 'Total Appointments',
            value: f.format(data.totalAppointments),
            trend: _pctChange(data.prevTotalAppointments, data.totalAppointments),
            trendDirection: _dir(data.prevTotalAppointments, data.totalAppointments),
            sparkline: KpiSparklineArea(data: data.completedTrend.map((p) => p.value).toList()),
          ),
        ),
        SizedBox(
          width: 200,
          child: KPICard(
            icon: FontAwesomeIcons.circleCheck,
            title: 'Completed',
            value: f.format(data.completedAppointments),
            trendDirection: TrendDirection.neutral,
            sparkline: KpiSparklineArea(
                data: data.completedTrend.map((p) => p.value).toList(),
                color: AppColors.success),
          ),
        ),
        SizedBox(
          width: 200,
          child: KPICard(
            icon: FontAwesomeIcons.personCircleXmark,
            title: 'No-Show Rate',
            value: '${data.noShowRate.toStringAsFixed(1)}%',
            trendDirection: data.noShowRate > 10 ? TrendDirection.down : TrendDirection.up,
            sparkline: KpiSparklineArea(
                data: data.noShowTrend.map((p) => p.value).toList(), color: AppColors.danger),
          ),
        ),
        SizedBox(
          width: 200,
          child: KPICard(
            icon: FontAwesomeIcons.sackDollar,
            title: 'Total Revenue',
            value: 'ETB ${etb.format(data.totalRevenueEtb)}',
            trend: _pctChange(data.prevTotalRevenueEtb, data.totalRevenueEtb),
            trendDirection: _dir(data.prevTotalRevenueEtb, data.totalRevenueEtb),
          ),
        ),
        SizedBox(
          width: 200,
          child: KPICard(
            icon: FontAwesomeIcons.userPlus,
            title: 'New Patients',
            value: f.format(data.newPatients),
            trend: _pctChange(data.prevNewPatients, data.newPatients),
            trendDirection: _dir(data.prevNewPatients, data.newPatients),
          ),
        ),
        SizedBox(
          width: 200,
          child: KPICard(
            icon: FontAwesomeIcons.gaugeHigh,
            title: 'Doctor Utilization',
            value: '${data.doctorUtilizationPercent.toStringAsFixed(1)}%',
            trendDirection: data.doctorUtilizationPercent >= 80 ? TrendDirection.up : TrendDirection.neutral,
          ),
        ),
      ],
    );
  }
}

class _VolumeTrendCard extends StatelessWidget {
  final AnalyticsSummary data;
  final DateRangeSelection range;
  const _VolumeTrendCard({required this.data, required this.range});

  @override
  Widget build(BuildContext context) {
    return LineChartCard(
      title: 'Patient Volume Trends',
      subtitle: range.label,
      series: [
        ChartSeries(
          name: 'Completed',
          data: data.completedTrend.map((p) => MapEntry(p.date, p.value)).toList(),
          color: AppColors.success,
        ),
        ChartSeries(
          name: 'Cancelled',
          data: data.cancelledTrend.map((p) => MapEntry(p.date, p.value)).toList(),
          color: AppColors.warning,
        ),
        ChartSeries(
          name: 'No-Show',
          data: data.noShowTrend.map((p) => MapEntry(p.date, p.value)).toList(),
          color: AppColors.danger,
        ),
      ],
    );
  }
}

class _StatusDonutCard extends StatelessWidget {
  final AnalyticsSummary data;
  const _StatusDonutCard({required this.data});

  static const _sliceColors = {
    'pending': AppColors.warning,
    'confirmed': AppColors.info,
    'completed': AppColors.success,
    'cancelled': AppColors.neutral400,
    'noShow': AppColors.danger,
    'no_show': AppColors.danger,
    'inProgress': AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final total = data.statusDistribution.values.fold(0, (a, b) => a + b);
    return DonutChartCard(
      title: 'Status Distribution',
      subtitle: 'All statuses',
      centerLabel: total.toString(),
      centerSubLabel: 'Total',
      slices: data.statusDistribution.entries
          .where((e) => e.value > 0)
          .map((e) => DonutSlice(
                label: _capitalize(e.key),
                value: e.value.toDouble(),
                color: _sliceColors[e.key] ?? AppColors.neutral400,
              ))
          .toList(),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _DateRangeBar extends StatelessWidget {
  final DateRangePreset selected;
  final bool compare;
  final ValueChanged<DateRangePreset> onPresetChanged;
  final ValueChanged<bool> onCompareToggled;
  const _DateRangeBar({
    required this.selected,
    required this.compare,
    required this.onPresetChanged,
    required this.onCompareToggled,
  });

  @override
  Widget build(BuildContext context) {
    const presets = [
      DateRangePreset.today,
      DateRangePreset.last7,
      DateRangePreset.last30,
      DateRangePreset.last90,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: AppRadius.radiusMd,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: presets.map((p) {
              final isSelected = p == selected;
              return GestureDetector(
                onTap: () => onPresetChanged(p),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Text(
                    DateRangeSelection.preset(p).label,
                    style: AppTypography.caption.copyWith(
                      color: isSelected ? Colors.white : AppColors.neutral600,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: compare,
              onChanged: onCompareToggled,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text('Compare', style: AppTypography.caption.copyWith(color: AppColors.neutral600)),
          ],
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ExportFormat>(
      tooltip: 'Export',
      icon: const Icon(Icons.download_outlined, size: 18),
      onSelected: (f) => context.read<AnalyticsDashboardBloc>().add(AnalyticsExportRequested(f)),
      itemBuilder: (_) => const [
        PopupMenuItem(value: ExportFormat.csv, child: Text('Export CSV')),
        PopupMenuItem(value: ExportFormat.pdf, child: Text('Export PDF')),
      ],
    );
  }
}

extension _ListSorted<T> on List<T> {
  List<T> sorted(Comparator<T> compare) => [...this]..sort(compare);
}
