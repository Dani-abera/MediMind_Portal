import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../bloc/platform_analytics/platform_analytics_bloc.dart';

class PlatformAnalyticsPage extends StatelessWidget {
  final int initialTab;
  const PlatformAnalyticsPage({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlatformAnalyticsBloc>()..add(const PlatformAnalyticsStarted()),
      child: _AnalyticsView(initialTab: initialTab),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  final int initialTab;
  const _AnalyticsView({required this.initialTab});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Column(
        children: [
          const PageHeader(
            title: 'Platform Analytics',
            subtitle: 'System-wide analytics and metrics',
          ),
          const TabBar(tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Revenue'),
            Tab(text: 'Growth'),
          ]),
          Expanded(
            child: BlocBuilder<PlatformAnalyticsBloc, PlatformAnalyticsState>(
              builder: (ctx, state) {
                if (state is PlatformAnalyticsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PlatformAnalyticsError) {
                  return Center(child: Text(state.message, style: TextStyle(color: AppColors.danger)));
                }
                if (state is! PlatformAnalyticsLoaded) {
                  return const SizedBox.shrink();
                }
                final analytics = state.analytics;
                final etb = NumberFormat('#,###.0');

                return TabBarView(children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.base),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Summary', style: AppTypography.h3),
                                const SizedBox(height: AppSpacing.base),
                                _row('Total Revenue', 'ETB ${etb.format(analytics.totalRevenueEtb)}'),
                                _row('Churn Rate (30d)', '${analytics.churnRate30d.toStringAsFixed(1)}%'),
                                _row('Churn Rate (60d)', '${analytics.churnRate60d.toStringAsFixed(1)}%'),
                                _row('Churn Rate (90d)', '${analytics.churnRate90d.toStringAsFixed(1)}%'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Top 20 Centers by Revenue', style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.base),
                        ...analytics.revenueByCenterTop20.map((c) => Padding(
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
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('New Centers Per Month', style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.base),
                        ...analytics.newCentersPerMonth.entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                              child: Row(
                                children: [
                                  Expanded(child: Text(e.key, style: AppTypography.bodySmall)),
                                  Text('${e.value}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )),
                        const SizedBox(height: AppSpacing.xl),
                        Text('New Doctors Per Month', style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.base),
                        ...analytics.newDoctorsPerMonth.entries.map((e) => Padding(
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
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(width: 160, child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500))),
            Expanded(child: Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
