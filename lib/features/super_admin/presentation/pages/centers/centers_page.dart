import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../domain/entities/platform_center.dart';
import '../../bloc/centers/centers_bloc.dart';

class CentersPage extends StatelessWidget {
  final int initialTab;
  const CentersPage({super.key, this.initialTab = 0});

  static String? _filterForTab(int tab) => switch (tab) {
        1 => 'pending',
        2 => 'active',
        3 => 'suspended',
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CentersBloc>()
        ..add(CentersStarted(statusFilter: _filterForTab(initialTab))),
      child: _CentersView(initialTab: initialTab),
    );
  }
}

class _CentersView extends StatelessWidget {
  final int initialTab;
  const _CentersView({required this.initialTab});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CentersBloc, CentersState>(
      listener: (ctx, state) {
        if (state is CentersActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is CentersActionError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: DefaultTabController(
        length: 4,
        initialIndex: initialTab,
        child: Column(
          children: [
            PageHeader(
              title: 'Health Centers',
              subtitle: 'Manage all healthcare centers',
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () => context.read<CentersBloc>().add(const CentersRefreshed()),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            TabBar(
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Active'),
                Tab(text: 'Suspended'),
              ],
              onTap: (i) {
                final filter = switch (i) {
                  1 => 'pending',
                  2 => 'active',
                  3 => 'suspended',
                  _ => null,
                };
                context.read<CentersBloc>().add(CentersFiltered(statusFilter: filter));
              },
            ),
            Expanded(
              child: BlocBuilder<CentersBloc, CentersState>(
                builder: (ctx, state) {
                  final centers = state is CentersLoaded ? state.centers : <PlatformCenter>[];
                  final total = state is CentersLoaded ? state.total : 0;
                  final page = state is CentersLoaded ? state.page : 1;
                  const pageSize = 20;
                  final isLoading = state is CentersLoading;

                  return AppDataTable<PlatformCenter>(
                    rows: centers,
                    isLoading: isLoading,
                    selectable: false,
                    emptyMessage: 'No centers found',
                    pagination: PaginationConfig(
                      page: page,
                      pageSize: pageSize,
                      total: total,
                      onPageChanged: (p) => ctx.read<CentersBloc>().add(CentersPageChanged(p)),
                      onPageSizeChanged: (_) {},
                    ),
                    rowActionsBuilder: (center) => _CenterActions(center: center),
                    columns: [
                      DataTableColumn(
                        label: 'Name',
                        builder: (c) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                            Text(c.type, style: AppTypography.caption.copyWith(color: AppColors.neutral400)),
                          ],
                        ),
                      ),
                      DataTableColumn(
                        label: 'Location',
                        width: 130,
                        builder: (c) => Text('${c.city}, ${c.region}', style: AppTypography.bodySmall),
                      ),
                      DataTableColumn(
                        label: 'Admin',
                        builder: (c) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.adminName, style: AppTypography.bodySmall),
                            Text(c.adminEmail, style: AppTypography.caption.copyWith(color: AppColors.neutral400)),
                          ],
                        ),
                      ),
                      DataTableColumn(
                        label: 'Subscription',
                        width: 100,
                        builder: (c) => _SubscriptionBadge(status: c.subscriptionStatus),
                      ),
                      DataTableColumn(
                        label: 'Doctors',
                        width: 70,
                        builder: (c) => Text('${c.doctorCount}', style: AppTypography.bodySmall),
                      ),
                      DataTableColumn(
                        label: 'Status',
                        width: 90,
                        builder: (c) => _StatusBadge(status: c.status),
                      ),
                      DataTableColumn(
                        label: 'Created',
                        width: 100,
                        builder: (c) => Text(
                          DateFormat('MMM d, y').format(c.createdAt),
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
      ),
    );
  }
}

class _CenterActions extends StatelessWidget {
  final PlatformCenter center;
  const _CenterActions({required this.center});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      itemBuilder: (_) => [
        if (center.status == CenterStatus.pending) ...[
          const PopupMenuItem(value: 'approve', child: Text('Approve')),
          const PopupMenuItem(value: 'reject', child: Text('Reject')),
        ],
        if (center.status == CenterStatus.active)
          const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
        if (center.status == CenterStatus.suspended)
          const PopupMenuItem(value: 'reactivate', child: Text('Reactivate')),
      ],
      onSelected: (action) async {
        switch (action) {
          case 'approve':
            final confirmed = await ConfirmDialog.show(
              context,
              title: 'Approve Center',
              message: 'Approve "${center.name}"? This will start the trial period.',
              confirmLabel: 'Approve',
            );
            if (confirmed && context.mounted) {
              context.read<CentersBloc>().add(CenterApproveRequested(
                    center.id,
                    DateTime.now().add(const Duration(days: 30)),
                  ));
            }
          case 'reject':
            if (context.mounted) {
              final reasonCtrl = TextEditingController();
              final reason = await showDialog<String>(
                context: context,
                builder: (_) => _RejectReasonDialog(reasonCtrl: reasonCtrl),
              );
              if (reason != null && reason.isNotEmpty && context.mounted) {
                context.read<CentersBloc>().add(CenterRejectRequested(center.id, reason));
              }
            }
          case 'suspend':
            final confirmed = await ConfirmDialog.show(
              context,
              title: 'Suspend Center',
              message: 'Suspend "${center.name}"? This will disable all access.',
              confirmLabel: 'Suspend',
              isDangerous: true,
            );
            if (confirmed && context.mounted) {
              context.read<CentersBloc>().add(CenterSuspendRequested(center.id, 'Suspended by admin'));
            }
          case 'reactivate':
            if (context.mounted) {
              context.read<CentersBloc>().add(CenterReactivateRequested(center.id));
            }
        }
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CenterStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CenterStatus.active => ('Active', AppColors.success),
      CenterStatus.suspended => ('Suspended', AppColors.danger),
      CenterStatus.rejected => ('Rejected', AppColors.neutral400),
      CenterStatus.pending => ('Pending', AppColors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _RejectReasonDialog extends StatefulWidget {
  final TextEditingController reasonCtrl;
  const _RejectReasonDialog({required this.reasonCtrl});

  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  bool _isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Registration'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Provide a reason — the center admin will see this.',
              style: AppTypography.body.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.reasonCtrl,
              autofocus: true,
              maxLines: 3,
              onChanged: (v) => setState(() => _isEmpty = v.trim().isEmpty),
              decoration: const InputDecoration(
                labelText: 'Rejection Reason *',
                hintText: 'e.g. Invalid license, missing documents...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isEmpty
              ? null
              : () => Navigator.pop(context, widget.reasonCtrl.text.trim()),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}

class _SubscriptionBadge extends StatelessWidget {
  final String status;
  const _SubscriptionBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'premium' => AppColors.primary,
      'basic' => AppColors.info,
      'suspended' => AppColors.danger,
      _ => AppColors.neutral400,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
