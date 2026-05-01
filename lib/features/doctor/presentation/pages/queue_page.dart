import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../../../core/widgets/status_badges/status_badge.dart';
import '../../domain/entities/queue_entry.dart';
import '../bloc/queue/queue_bloc.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QueueBloc>()..add(const QueueStarted()),
      child: const _QueueView(),
    );
  }
}

class _QueueView extends StatefulWidget {
  const _QueueView();

  @override
  State<_QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends State<_QueueView> {
  String? _selectedCenterId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: "Today's Queue",
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh',
              onPressed: () => context.read<QueueBloc>().add(const QueueRefreshed()),
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<QueueBloc, QueueState>(
            builder: (context, state) {
              if (state is QueueLoading || state is QueueInitial) {
                return const Center(child: AppLoadingSpinner());
              }
              if (state is QueueError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () => context.read<QueueBloc>().add(const QueueRefreshed()),
                );
              }
              if (state is QueueLoaded) {
                return _buildQueueList(context, state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQueueList(BuildContext context, QueueLoaded state) {
    final entries = state.entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.base,
          ),
          child: Row(
            children: [
              Text('${entries.length} patients in queue',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
              const Spacer(),
              _buildCenterSelector(context, state),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: entries.isEmpty
              ? const AppEmptyState(
                  message: 'No patients in queue',
                  description: 'The queue is currently empty.',
                  icon: Icons.people_outline,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _QueueEntryCard(entry: entries[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildCenterSelector(BuildContext context, QueueLoaded state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Center: ', style: AppTypography.bodySmall),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _selectedCenterId ?? state.centerId,
          hint: const Text('All Centers'),
          isDense: true,
          underline: const SizedBox.shrink(),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Centers'),
            ),
            if (state.centerId != null)
              DropdownMenuItem<String>(
                value: state.centerId,
                child: Text(state.centerId!),
              ),
          ],
          onChanged: (value) {
            setState(() => _selectedCenterId = value);
            if (value != null) {
              context.read<QueueBloc>().add(QueueCenterChanged(value));
            }
          },
        ),
      ],
    );
  }
}

class _QueueEntryCard extends StatelessWidget {
  final QueueEntry entry;

  const _QueueEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(entry.status);
    final statusBadge = _statusBadge(entry.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.radiusBase,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              borderRadius: AppRadius.radiusBase,
            ),
            child: Center(
              child: Text(
                '#${entry.queueNumber}',
                style: AppTypography.h3.copyWith(
                  color: statusColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.patientName,
                      style: AppTypography.bodyMedium,
                    ),
                    if (entry.patientAge != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${entry.patientAge}y',
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.reason,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(entry.appointmentTime),
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 4),
              statusBadge,
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(QueueStatus status) {
    return switch (status) {
      QueueStatus.waiting => AppColors.warning,
      QueueStatus.inProgress => AppColors.info,
      QueueStatus.done => AppColors.success,
      QueueStatus.skipped => AppColors.neutral400,
    };
  }

  Widget _statusBadge(QueueStatus status) {
    return switch (status) {
      QueueStatus.waiting => const StatusBadge(label: 'Waiting', status: BadgeStatus.pending),
      QueueStatus.inProgress =>
        const StatusBadge(label: 'In Progress', status: BadgeStatus.inProgress),
      QueueStatus.done => const StatusBadge(label: 'Done', status: BadgeStatus.completed),
      QueueStatus.skipped => const StatusBadge(label: 'Skipped', status: BadgeStatus.noShow),
    };
  }
}
