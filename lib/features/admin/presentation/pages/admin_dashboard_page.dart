import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/user_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/cards/chart_card.dart';
import '../../../../core/widgets/cards/kpi_card.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../domain/entities/admin_dashboard_data.dart';
import '../../domain/entities/queue_item.dart';
import '../bloc/branding/branding_bloc.dart';
import '../bloc/center_settings/center_settings_bloc.dart';
import '../bloc/dashboard/admin_dashboard_bloc.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<CenterSettingsBloc>()
            ..add(CenterSettingsStarted(UserContext().centerId ?? '')),
        ),
        BlocProvider(
          create: (_) => sl<BrandingBloc>()
            ..add(BrandingStarted(UserContext().centerId ?? '')),
        ),
      ],
      child: BlocProvider(
        create: (_) => sl<AdminDashboardBloc>()..add(const AdminDashboardStarted()),
        child: const _AdminDashboardView(),
      ),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'Dashboard',
          subtitle: 'Health Center Overview',
          actions: [
            BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
              builder: (ctx, state) {
                if (state is AdminDashboardLoaded) {
                  return Text(
                    'Updated ${DateFormat('h:mm a').format(state.lastRefreshed)}',
                    style: AppTypography.caption.copyWith(color: AppColors.neutral400),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh',
              onPressed: () => context.read<AdminDashboardBloc>().add(const AdminDashboardRefreshed()),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
            builder: (ctx, state) {
              if (state is AdminDashboardLoading || state is AdminDashboardInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AdminDashboardError) {
                return Center(child: Text(state.message, style: AppTypography.body));
              }
              if (state is AdminDashboardLoaded) {
                return _DashboardBody(data: state.data);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final AdminDashboardData data;
  const _DashboardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CenterInfoBanner(),
          const SizedBox(height: AppSpacing.base),
          _KpiRow(data: data),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _AppointmentStatusChart(data: data)),
              const SizedBox(width: AppSpacing.base),
              Expanded(flex: 2, child: _QueueSnapshot(items: data.recentQueue, queueLength: data.queueLength)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _HourlyVolumeChart(data: data)),
              const SizedBox(width: AppSpacing.base),
              Expanded(flex: 2, child: _DoctorUtilization(data: data)),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final AdminDashboardData data;
  const _KpiRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final revenueSign = data.revenueChangePercent >= 0 ? '+' : '';
    return Row(
      children: [
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.calendarCheck,
            title: "Today's Appointments",
            value: '${data.todayAppointmentsTotal}',
            trend: '+${data.confirmedCount} confirmed',
            trendDirection: TrendDirection.up,
          ),
        ),
        const SizedBox(width: AppSpacing.base),
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.listOl,
            title: 'Queue Length',
            value: '${data.queueLength}',
            trend: 'Avg ${data.avgWaitMinutes.toStringAsFixed(0)} min wait',
            trendDirection: data.avgWaitMinutes > 20 ? TrendDirection.down : TrendDirection.neutral,
          ),
        ),
        const SizedBox(width: AppSpacing.base),
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.userDoctor,
            title: 'Active Doctors',
            value: '${data.activeDoctors}',
            trend: 'of ${data.totalDoctors} total',
            trendDirection: TrendDirection.neutral,
          ),
        ),
        const SizedBox(width: AppSpacing.base),
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.moneyBillWave,
            title: "Today's Revenue",
            value: 'ETB ${_fmtNumber(data.todayRevenueEtb)}',
            trend: '$revenueSign${data.revenueChangePercent.toStringAsFixed(1)}% vs yesterday',
            trendDirection: data.revenueChangePercent >= 0 ? TrendDirection.up : TrendDirection.down,
          ),
        ),
      ],
    );
  }

  String _fmtNumber(double n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toStringAsFixed(0);
  }
}

class _AppointmentStatusChart extends StatelessWidget {
  final AdminDashboardData data;
  const _AppointmentStatusChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.todayAppointmentsTotal;
    if (total == 0) {
      return ChartCard(
        title: 'Appointment Status',
        subtitle: 'Today',
        child: const SizedBox(height: 220, child: Center(child: Text('No appointments today'))),
      );
    }

    final sections = [
      _section(data.confirmedCount, AppColors.info, 'Confirmed'),
      _section(data.pendingCount, AppColors.warning, 'Pending'),
      _section(data.cancelledCount, AppColors.danger, 'Cancelled'),
      _section(
        total - data.confirmedCount - data.pendingCount - data.cancelledCount,
        AppColors.success,
        'Completed',
      ),
    ].where((s) => s.value > 0).toList();

    return ChartCard(
      title: 'Appointment Status',
      subtitle: 'Today · $total total',
      child: SizedBox(
        height: 220,
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 48,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legend(AppColors.info, 'Confirmed', data.confirmedCount),
                _legend(AppColors.warning, 'Pending', data.pendingCount),
                _legend(AppColors.success, 'Completed',
                    total - data.confirmedCount - data.pendingCount - data.cancelledCount),
                _legend(AppColors.danger, 'Cancelled', data.cancelledCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _section(int count, Color color, String title) {
    return PieChartSectionData(
      value: count.toDouble(),
      color: color,
      title: '',
      radius: 40,
    );
  }

  Widget _legend(Color color, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label ($count)', style: AppTypography.caption.copyWith(color: AppColors.neutral600)),
        ],
      ),
    );
  }
}

class _QueueSnapshot extends StatelessWidget {
  final List<QueueItem> items;
  final int queueLength;
  const _QueueSnapshot({required this.items, required this.queueLength});

  @override
  Widget build(BuildContext context) {
    final waiting = items.where((i) => i.status == QueueStatus.waiting).take(5).toList();
    return ChartCard(
      title: 'Live Queue',
      subtitle: '$queueLength waiting now',
      child: SizedBox(
        height: 220,
        child: waiting.isEmpty
            ? const Center(child: Text('Queue is empty', style: TextStyle(color: AppColors.neutral400)))
            : ListView.separated(
                itemCount: waiting.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final item = waiting[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withAlpha(80),
                            borderRadius: AppRadius.radiusFull,
                          ),
                          child: Center(
                            child: Text(
                              '${item.queueNumber}',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(item.patientName,
                                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                              Text(item.doctorName,
                                  style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        if (item.estimatedWaitMinutes != null)
                          Text(
                            '~${item.estimatedWaitMinutes}m',
                            style: AppTypography.caption.copyWith(color: AppColors.neutral400),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _HourlyVolumeChart extends StatelessWidget {
  final AdminDashboardData data;
  const _HourlyVolumeChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.hourlyVolume.isEmpty) {
      return ChartCard(
        title: 'Hourly Volume',
        subtitle: 'Today',
        child: const SizedBox(height: 200, child: Center(child: Text('No data'))),
      );
    }

    final maxY = data.hourlyVolume.fold(0, (m, v) => v.count > m ? v.count : m).toDouble();

    return ChartCard(
      title: 'Hourly Volume',
      subtitle: 'Appointments per hour today',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY + 2,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, meta) {
                    final h = val.toInt();
                    if (h % 2 != 0) return const SizedBox.shrink();
                    final label = h == 0 ? '12a' : h < 12 ? '${h}a' : h == 12 ? '12p' : '${h - 12}p';
                    return Text(label, style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.neutral400));
                  },
                  reservedSize: 22,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
                  getTitlesWidget: (val, _) => Text(
                    val.toInt().toString(),
                    style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.neutral400),
                  ),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: AppColors.neutral100, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.hourlyVolume
                .map((v) => BarChartGroupData(
                      x: v.hour,
                      barRods: [
                        BarChartRodData(
                          toY: v.count.toDouble(),
                          color: AppColors.primary,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _DoctorUtilization extends StatelessWidget {
  final AdminDashboardData data;
  const _DoctorUtilization({required this.data});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Doctor Utilization',
      subtitle: 'Today',
      child: SizedBox(
        height: 200,
        child: data.doctorUtilization.isEmpty
            ? const Center(child: Text('No data', style: TextStyle(color: AppColors.neutral400)))
            : ListView.separated(
                itemCount: data.doctorUtilization.length.clamp(0, 5),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final d = data.doctorUtilization[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              d.doctorName,
                              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${d.utilizationPercent.toStringAsFixed(0)}%',
                            style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: AppRadius.radiusFull,
                        child: LinearProgressIndicator(
                          value: (d.utilizationPercent / 100).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppColors.neutral100,
                          valueColor: AlwaysStoppedAnimation(
                            d.utilizationPercent > 80 ? AppColors.danger :
                            d.utilizationPercent > 60 ? AppColors.warning : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _CenterInfoBanner extends StatelessWidget {
  const _CenterInfoBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CenterSettingsBloc, CenterSettingsState>(
      builder: (_, settingsState) {
        return BlocBuilder<BrandingBloc, BrandingState>(
          builder: (_, brandingState) {
            final config = settingsState is CenterSettingsLoaded ? settingsState.config : null;
            if (config == null) return const SizedBox.shrink();
            final branding = brandingState is BrandingLoaded ? brandingState.branding : null;
            final logoUrl = branding?.logoUrl;
            final initials = config.name.isNotEmpty ? config.name[0].toUpperCase() : 'C';
            final location = [config.city, config.region]
                .where((s) => s.isNotEmpty)
                .join(' · ');
            return Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: AppRadius.radiusXl,
                border: Border.all(color: AppColors.neutral200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
                    child: logoUrl == null
                        ? Text(
                            initials,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(config.name, style: AppTypography.h3),
                        if (location.isNotEmpty)
                          Text(
                            location,
                            style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                          ),
                      ],
                    ),
                  ),
                  if (config.specializations.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ...config.specializations.take(3).map(
                              (s) => Chip(
                                label: Text(s, style: AppTypography.caption),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                        if (config.specializations.length > 3)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              '+${config.specializations.length - 3} more',
                              style: AppTypography.caption.copyWith(color: AppColors.neutral400),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
