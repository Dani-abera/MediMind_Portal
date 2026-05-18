import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/user_context.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../../../core/widgets/status_badges/status_badge.dart';
import '../../../domain/entities/queue_item.dart';
import '../../bloc/queue/admin_queue_bloc.dart';

class LiveQueuePage extends StatelessWidget {
  const LiveQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminQueueBloc>()
        ..add(AdminQueueOpened(UserContext().centerId ?? '')),
      child: const _LiveQueueView(),
    );
  }
}

class _LiveQueueView extends StatelessWidget {
  const _LiveQueueView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'Live Queue',
          subtitle: 'Real-time patient queue management',
          actions: [
            BlocBuilder<AdminQueueBloc, AdminQueueState>(
              buildWhen: (p, c) => c is AdminQueueLoaded,
              builder: (ctx, state) {
                if (state is AdminQueueLoaded) {
                  return Text(
                    'Updated ${DateFormat('h:mm:ss a').format(state.updatedAt)}',
                    style: AppTypography.caption.copyWith(color: AppColors.neutral400),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh',
              onPressed: () => context.read<AdminQueueBloc>().add(const AdminQueueRefreshed()),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        BlocListener<AdminQueueBloc, AdminQueueState>(
          listener: (ctx, state) {
            if (state is AdminQueueActionError) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
              );
            } else if (state is AdminQueueActionSuccess) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
              );
            }
          },
          child: const SizedBox.shrink(),
        ),
        Expanded(
          child: BlocBuilder<AdminQueueBloc, AdminQueueState>(
            builder: (ctx, state) {
              if (state is AdminQueueLoading || state is AdminQueueInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AdminQueueError) {
                return Center(child: Text(state.message, style: AppTypography.body));
              }
              if (state is AdminQueueLoaded) {
                return _QueueBody(state: state);
              }
              if (state is AdminQueueActionInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _QueueBody extends StatelessWidget {
  final AdminQueueLoaded state;
  const _QueueBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _QueueList(
            items: state.items,
            nowServing: state.nowServing,
          ),
        ),
        Container(width: 1, color: AppColors.neutral200),
        Expanded(
          flex: 2,
          child: _QueueStats(stats: state.stats),
        ),
      ],
    );
  }
}

class _QueueList extends StatelessWidget {
  final List<QueueItem> items;
  final QueueItem? nowServing;

  const _QueueList({required this.items, this.nowServing});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminQueueBloc>();
    final waiting = items.where((i) => i.status == QueueStatus.waiting).toList();
    final inProgress = items.where((i) => i.status == QueueStatus.inProgress).toList();

    return Column(
      children: [
        if (inProgress.isNotEmpty) ...[
          _NowServingCard(item: inProgress.first),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.sm),
          child: Row(
            children: [
              Text('Waiting (${waiting.length})',
                  style: AppTypography.h3.copyWith(color: AppColors.neutral700)),
              const Spacer(),
              AppButton.primary(
                label: 'Call Next',
                icon: FontAwesomeIcons.circleArrowRight,
                onPressed: waiting.isEmpty
                    ? null
                    : () => bloc.add(const AdminQueueNextCalled()),
              ),
            ],
          ),
        ),
        Expanded(
          child: waiting.isEmpty
              ? const Center(
                  child: Text('No patients waiting', style: TextStyle(color: AppColors.neutral400)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  itemCount: waiting.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (ctx, i) => _QueueItemCard(item: waiting[i]),
                ),
        ),
      ],
    );
  }
}

class _NowServingCard extends StatelessWidget {
  final QueueItem item;
  const _NowServingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminQueueBloc>();
    return Container(
      margin: const EdgeInsets.all(AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withAlpha(60),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
        borderRadius: AppRadius.radiusBase,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_circle, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text('Now Serving',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.radiusFull,
                ),
                child: Text('#${item.queueNumber}',
                    style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.patientName, style: AppTypography.h2),
          if (item.patientAge != null)
            Text('Age ${item.patientAge}', style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
          const SizedBox(height: 6),
          Text('${item.doctorName}${item.room != null ? ' · Room ${item.room}' : ''}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              AppButton.primary(
                label: 'Complete',
                icon: FontAwesomeIcons.circleCheck,
                onPressed: () => bloc.add(AdminQueueMarkComplete(item.id)),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton.secondary(
                label: 'No Show',
                onPressed: () => bloc.add(AdminQueueMarkNoShow(item.id)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueItemCard extends StatelessWidget {
  final QueueItem item;
  const _QueueItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminQueueBloc>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: AppRadius.radiusBase,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppRadius.radiusFull,
            ),
            child: Center(
              child: Text(
                '${item.queueNumber}',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.neutral700),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
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
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Text(
                '~${item.estimatedWaitMinutes}m',
                style: AppTypography.caption.copyWith(color: AppColors.neutral400),
              ),
            ),
          _statusBadge(item.status),
          const SizedBox(width: AppSpacing.sm),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 16, color: AppColors.neutral400),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'arrived', child: Text('Mark Arrived')),
              const PopupMenuItem(value: 'skip', child: Text('Skip')),
              const PopupMenuItem(value: 'noshow', child: Text('No Show')),
            ],
            onSelected: (v) async {
              switch (v) {
                case 'arrived':
                  bloc.add(AdminQueueMarkArrived(item.id));
                case 'skip':
                  final ok = await ConfirmDialog.show(
                    context,
                    title: 'Skip Patient',
                    message: 'Skip ${item.patientName} and move them to the end?',
                  );
                  if (ok && context.mounted) bloc.add(AdminQueueSkipped(item.id));
                case 'noshow':
                  final ok = await ConfirmDialog.show(
                    context,
                    title: 'Mark No Show',
                    message: 'Mark ${item.patientName} as no-show?',
                    isDangerous: true,
                  );
                  if (ok && context.mounted) bloc.add(AdminQueueMarkNoShow(item.id));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(QueueStatus status) {
    return switch (status) {
      QueueStatus.waiting => const StatusBadge(label: 'Waiting', status: BadgeStatus.pending),
      QueueStatus.inProgress => const StatusBadge(label: 'In Progress', status: BadgeStatus.inProgress),
      QueueStatus.done => const StatusBadge(label: 'Done', status: BadgeStatus.completed),
      QueueStatus.noShow => const StatusBadge(label: 'No Show', status: BadgeStatus.noShow),
      QueueStatus.skipped => const StatusBadge(label: 'Skipped', status: BadgeStatus.expired),
    };
  }
}

class _QueueStats extends StatelessWidget {
  final QueueStats stats;
  const _QueueStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Queue Summary', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.base),
          _StatRow(label: 'Total Served', value: '${stats.totalServed}'),
          _StatRow(label: 'No Shows', value: '${stats.noShowCount}'),
          _StatRow(
            label: 'Avg Wait',
            value: stats.avgWaitMinutes > 0 ? '${stats.avgWaitMinutes.toStringAsFixed(0)} min' : '—',
          ),
          _StatRow(
            label: 'Avg Consultation',
            value: stats.avgConsultationMinutes > 0
                ? '${stats.avgConsultationMinutes.toStringAsFixed(0)} min'
                : '—',
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('By Doctor', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          if (stats.doctorStats.isEmpty)
            Text('No data', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400))
          else
            ...stats.doctorStats.map((d) => _DoctorStatTile(stat: d)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
          const Spacer(),
          Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DoctorStatTile extends StatelessWidget {
  final DoctorQueueStat stat;
  const _DoctorStatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.radiusBase,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(stat.doctorName,
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
              if (stat.inConsultation)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Served: ${stat.served}',
                  style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
              const SizedBox(width: 12),
              Text('Remaining: ${stat.remaining}',
                  style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
            ],
          ),
        ],
      ),
    );
  }
}
