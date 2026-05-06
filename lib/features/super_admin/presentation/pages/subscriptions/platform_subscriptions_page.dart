import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../domain/entities/platform_subscription.dart';
import '../../bloc/subscriptions/platform_subscriptions_bloc.dart';

class PlatformSubscriptionsPage extends StatelessWidget {
  const PlatformSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlatformSubscriptionsBloc>()..add(const PlatformSubscriptionsStarted()),
      child: const _SubscriptionsView(),
    );
  }
}

class _SubscriptionsView extends StatelessWidget {
  const _SubscriptionsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlatformSubscriptionsBloc, PlatformSubscriptionsState>(
      listener: (ctx, state) {
        if (state is PlatformSubscriptionsActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is PlatformSubscriptionsActionError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Subscriptions',
            subtitle: 'Manage center subscriptions',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: () => context.read<PlatformSubscriptionsBloc>().add(const PlatformSubscriptionsRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<PlatformSubscriptionsBloc, PlatformSubscriptionsState>(
              builder: (ctx, state) {
                final subs = state is PlatformSubscriptionsLoaded ? state.subscriptions : <PlatformSubscription>[];
                final total = state is PlatformSubscriptionsLoaded ? state.total : 0;
                final page = state is PlatformSubscriptionsLoaded ? state.page : 1;
                const pageSize = 20;
                final isLoading = state is PlatformSubscriptionsLoading;

                return AppDataTable<PlatformSubscription>(
                  rows: subs,
                  isLoading: isLoading,
                  selectable: false,
                  emptyMessage: 'No subscriptions found',
                  pagination: PaginationConfig(
                    page: page,
                    pageSize: pageSize,
                    total: total,
                    onPageChanged: (p) => ctx.read<PlatformSubscriptionsBloc>().add(PlatformSubscriptionsPageChanged(p)),
                    onPageSizeChanged: (_) {},
                  ),
                  columns: [
                    DataTableColumn(
                      label: 'Center',
                      builder: (s) => Text(s.centerName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    DataTableColumn(
                      label: 'Plan',
                      width: 90,
                      builder: (s) => _PlanBadge(plan: s.plan),
                    ),
                    DataTableColumn(
                      label: 'Status',
                      width: 90,
                      builder: (s) => _StatusBadge(status: s.status),
                    ),
                    DataTableColumn(
                      label: 'MRR (ETB)',
                      width: 100,
                      builder: (s) => Text(
                        NumberFormat('#,###.0').format(s.mrrEtb),
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataTableColumn(
                      label: 'Days Left',
                      width: 80,
                      builder: (s) => Text(
                        '${s.daysRemaining}',
                        style: AppTypography.bodySmall.copyWith(
                          color: s.daysRemaining < 7 ? AppColors.danger : AppColors.neutral700,
                        ),
                      ),
                    ),
                    DataTableColumn(
                      label: 'End Date',
                      width: 110,
                      builder: (s) => Text(
                        DateFormat('MMM d, y').format(s.endDate),
                        style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final String plan;
  const _PlanBadge({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = switch (plan) {
      'premium' => AppColors.primary,
      'basic' => AppColors.info,
      _ => AppColors.neutral400,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(4)),
      child: Text(plan, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'active' => AppColors.success,
      'expired' => AppColors.warning,
      'suspended' => AppColors.danger,
      _ => AppColors.neutral400,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
