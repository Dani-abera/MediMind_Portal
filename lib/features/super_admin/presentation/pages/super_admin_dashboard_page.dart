import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cards/kpi_card.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../bloc/platform_dashboard/platform_dashboard_bloc.dart';

class SuperAdminDashboardPage extends StatelessWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlatformDashboardBloc>()..add(const PlatformDashboardStarted()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformDashboardBloc, PlatformDashboardState>(
      builder: (ctx, state) {
        if (state is PlatformDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PlatformDashboardError) {
          return Center(child: Text(state.message, style: TextStyle(color: AppColors.danger)));
        }

        final data = state is PlatformDashboardLoaded ? state.data : null;
        final etb = NumberFormat('#,###.0');

        return Column(
          children: [
            PageHeader(
              title: 'Dashboard',
              subtitle: 'System-wide overview',
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () => ctx.read<PlatformDashboardBloc>().add(const PlatformDashboardRefreshed()),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (data != null && (data.pendingApprovals > 0 || data.pendingLicenses > 0))
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${data.pendingApprovals} center${data.pendingApprovals != 1 ? 's' : ''} pending approval'
                      '${data.pendingLicenses > 0 ? ' · ${data.pendingLicenses} license${data.pendingLicenses != 1 ? 's' : ''} pending verification' : ''}',
                      style: AppTypography.bodySmall.copyWith(color: Colors.amber.shade900),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: KPICard(
                            icon: FontAwesomeIcons.hospital,
                            title: 'Health Centers',
                            value: '${data?.totalCenters ?? 0}',
                            trend: '${data?.activeCenters ?? 0} active',
                            trendDirection: TrendDirection.neutral,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: KPICard(
                            icon: FontAwesomeIcons.userDoctor,
                            title: 'Total Doctors',
                            value: '${data?.totalDoctors ?? 0}',
                            trend: '${data?.verifiedDoctors ?? 0} verified',
                            trendDirection: TrendDirection.neutral,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: KPICard(
                            icon: FontAwesomeIcons.userGroup,
                            title: 'Total Patients',
                            value: '${data?.totalPatients ?? 0}',
                            trend: '${data?.mau ?? 0} MAU',
                            trendDirection: TrendDirection.neutral,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: KPICard(
                            icon: FontAwesomeIcons.creditCard,
                            title: 'Monthly Revenue',
                            value: 'ETB ${etb.format(data?.monthlyRevenueEtb ?? 0)}',
                            trend: '',
                            trendDirection: TrendDirection.neutral,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (data != null && data.topCentersByRevenue.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Top Centers by Revenue', style: AppTypography.h3),
                              const SizedBox(height: AppSpacing.base),
                              ...data.topCentersByRevenue.take(5).map((c) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(c.centerName, style: AppTypography.bodySmall)),
                                        Text('ETB ${etb.format(c.revenueEtb)}',
                                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    if (data != null && data.subscriptionBreakdown.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.base),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Subscription Breakdown', style: AppTypography.h3),
                              const SizedBox(height: AppSpacing.base),
                              ...data.subscriptionBreakdown.entries.map((e) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(e.key, style: AppTypography.bodySmall)),
                                        Text('${e.value}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
