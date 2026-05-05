import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/user_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cards/kpi_card.dart';
import '../../../../core/widgets/charts/line_chart_card.dart';
import '../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../domain/entities/analytics_data.dart';
import '../domain/entities/revenue_data.dart';
import '../presentation/bloc/revenue/revenue_bloc.dart';

class RevenuePage extends StatelessWidget {
  const RevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RevenueBloc>()..add(RevenueStarted(UserContext().centerId ?? '')),
      child: const _RevenueView(),
    );
  }
}

class _RevenueView extends StatefulWidget {
  const _RevenueView();
  @override
  State<_RevenueView> createState() => _RevenueViewState();
}

class _RevenueViewState extends State<_RevenueView> {
  DateRangePreset _preset = DateRangePreset.last30;
  RevenueGroupBy _groupBy = RevenueGroupBy.day;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RevenueBloc, RevenueState>(
      listener: (ctx, state) {
        if (state is RevenueExportDone) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('CSV exported')));
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Revenue',
            subtitle: 'Financial performance',
            actions: [
              _GroupBySelector(
                selected: _groupBy,
                onChanged: (g) {
                  setState(() => _groupBy = g);
                  context.read<RevenueBloc>().add(RevenueGroupByChanged(g));
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              _DateRangeSelector(
                selected: _preset,
                onChanged: (p) {
                  setState(() => _preset = p);
                  context.read<RevenueBloc>().add(RevenueDateRangeChanged(p));
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.download_outlined, size: 18),
                tooltip: 'Export CSV',
                onPressed: () => context.read<RevenueBloc>().add(const RevenueExportRequested()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<RevenueBloc, RevenueState>(
              builder: (ctx, state) {
                if (state is RevenueLoading) return const Center(child: CircularProgressIndicator());
                if (state is RevenueError) {
                  return Center(child: Text(state.message, style: AppTypography.body.copyWith(color: AppColors.danger)));
                }
                if (state is RevenueLoaded) {
                  return _RevenueContent(data: state.data, range: state.range);
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

class _RevenueContent extends StatelessWidget {
  final RevenueSummary data;
  final DateRangeSelection range;
  const _RevenueContent({required this.data, required this.range});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KpiRow(data: data),
          const SizedBox(height: AppSpacing.xl),
          LineChartCard(
            title: 'Revenue Trend',
            subtitle: range.label,
            series: [
              ChartSeries(
                name: 'Revenue (ETB)',
                data: data.trend.map((p) => MapEntry(p.date, p.value)).toList(),
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _RevenueTable(rows: data.rows),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final RevenueSummary data;
  const _KpiRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final etb = NumberFormat('#,###.0');
    String pct(double? prev, double curr) {
      if (prev == null || prev == 0) return '';
      return '${((curr - prev) / prev * 100).toStringAsFixed(1)}%';
    }

    return Wrap(
      spacing: AppSpacing.base,
      runSpacing: AppSpacing.base,
      children: [
        _kpi('Total Revenue', 'ETB ${etb.format(data.totalRevenue)}',
            Icons.payments_outlined,
            trend: pct(data.prevTotalRevenue, data.totalRevenue),
            dir: (data.prevTotalRevenue ?? 0) <= data.totalRevenue ? TrendDirection.up : TrendDirection.down),
        _kpi('Pending', 'ETB ${etb.format(data.pendingPayments)}',
            Icons.hourglass_empty_outlined),
        _kpi('Refunded', 'ETB ${etb.format(data.refunded)}',
            Icons.replay_outlined),
        _kpi('Avg / Appointment', 'ETB ${etb.format(data.avgPerAppointment)}',
            Icons.calculate_outlined),
      ],
    );
  }

  Widget _kpi(String title, String value, IconData icon,
      {String? trend, TrendDirection dir = TrendDirection.neutral}) =>
      SizedBox(
        width: 210,
        child: KPICard(icon: icon, title: title, value: value, trend: trend, trendDirection: dir),
      );
}

class _RevenueTable extends StatelessWidget {
  final List<RevenueRow> rows;
  const _RevenueTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final etb = NumberFormat('#,###.0');
    return AppDataTable<RevenueRow>(
      rows: rows,
      isLoading: false,
      selectable: false,
      emptyMessage: 'No revenue records',
      columns: [
        DataTableColumn(
          label: 'Date',
          width: 100,
          builder: (r) => Text(DateFormat('MMM d, yyyy').format(r.date), style: AppTypography.bodySmall),
        ),
        DataTableColumn(
          label: 'Appt ID',
          width: 120,
          builder: (r) => Text(r.appointmentId.length > 12 ? '...${r.appointmentId.substring(r.appointmentId.length - 8)}' : r.appointmentId,
              style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
        ),
        DataTableColumn(
          label: 'Doctor',
          builder: (r) => Text(r.doctorName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        ),
        DataTableColumn(
          label: 'Patient',
          builder: (r) => Text(r.patientMasked, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600)),
        ),
        DataTableColumn(
          label: 'Amount',
          width: 100,
          builder: (r) => Text('ETB ${etb.format(r.amount)}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        ),
        DataTableColumn(
          label: 'Method',
          width: 100,
          builder: (r) => Text(r.method, style: AppTypography.bodySmall),
        ),
        DataTableColumn(
          label: 'Status',
          width: 90,
          builder: (r) => _statusChip(r.status),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status.toLowerCase()) {
      'completed' || 'paid' => AppColors.success,
      'pending'             => AppColors.warning,
      'failed'              => AppColors.danger,
      'refunded'            => AppColors.info,
      _                     => AppColors.neutral400,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: AppRadius.radiusFull),
      child: Text(status, style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 10)),
    );
  }
}

class _GroupBySelector extends StatelessWidget {
  final RevenueGroupBy selected;
  final ValueChanged<RevenueGroupBy> onChanged;
  const _GroupBySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<RevenueGroupBy>(
      style: SegmentedButton.styleFrom(
        textStyle: AppTypography.caption,
        visualDensity: VisualDensity.compact,
      ),
      segments: const [
        ButtonSegment(value: RevenueGroupBy.day, label: Text('Day')),
        ButtonSegment(value: RevenueGroupBy.week, label: Text('Week')),
        ButtonSegment(value: RevenueGroupBy.month, label: Text('Month')),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateRangePreset selected;
  final ValueChanged<DateRangePreset> onChanged;
  const _DateRangeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<DateRangePreset>(
      value: selected,
      style: AppTypography.bodySmall,
      underline: const SizedBox.shrink(),
      items: const [
        DropdownMenuItem(value: DateRangePreset.today, child: Text('Today')),
        DropdownMenuItem(value: DateRangePreset.last7, child: Text('Last 7 days')),
        DropdownMenuItem(value: DateRangePreset.last30, child: Text('Last 30 days')),
        DropdownMenuItem(value: DateRangePreset.last90, child: Text('Last 90 days')),
      ],
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}
