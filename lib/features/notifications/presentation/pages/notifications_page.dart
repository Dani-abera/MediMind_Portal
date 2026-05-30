import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../domain/entities/notification_item.dart';
import '../bloc/notifications_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsBloc>()..add(const NotificationsStarted()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listener: (ctx, state) {
        if (state is NotificationsActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is NotificationsActionError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Notifications',
            subtitle: 'Your recent alerts and updates',
            actions: [
              BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (ctx, state) {
                  final hasUnread = state is NotificationsLoaded &&
                      state.items.any((n) => !n.isRead);
                  return TextButton.icon(
                    onPressed: hasUnread
                        ? () => ctx
                            .read<NotificationsBloc>()
                            .add(const NotificationsMarkAllReadRequested())
                        : null,
                    icon: const Icon(Icons.done_all_outlined, size: 16),
                    label: const Text('Mark all read'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: () => context
                    .read<NotificationsBloc>()
                    .add(const NotificationsRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (ctx, state) {
                if (state is NotificationsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is NotificationsError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 40, color: AppColors.neutral400),
                        const SizedBox(height: AppSpacing.sm),
                        Text(state.message, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
                        const SizedBox(height: AppSpacing.base),
                        TextButton(
                          onPressed: () => ctx.read<NotificationsBloc>().add(const NotificationsRefreshed()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                final items = state is NotificationsLoaded ? state.items : <NotificationItem>[];
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_none_outlined, size: 48, color: AppColors.neutral300),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No notifications yet',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (ctx, i) => _NotificationCard(
                    item: items[i],
                    onMarkRead: items[i].isRead
                        ? null
                        : () => ctx
                            .read<NotificationsBloc>()
                            .add(NotificationMarkReadRequested(items[i].id)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onMarkRead;

  const _NotificationCard({required this.item, this.onMarkRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.neutral50 : Colors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(
          color: item.isRead ? AppColors.neutral200 : AppColors.primary.withAlpha(60),
        ),
        boxShadow: item.isRead
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withAlpha(12),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread dot
          Padding(
            padding: const EdgeInsets.only(top: 6, right: AppSpacing.sm),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isRead ? Colors.transparent : AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TypeBadge(type: item.notificationType),
                    const SizedBox(width: AppSpacing.xs),
                    _ChannelBadge(channel: item.channel),
                    const Spacer(),
                    _StatusBadge(status: item.status),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      DateFormat('MMM d, HH:mm').format(item.sentAt),
                      style: AppTypography.caption.copyWith(color: AppColors.neutral400),
                    ),
                  ],
                ),
                if (item.title != null && item.title!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.title!,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onMarkRead != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Tooltip(
              message: 'Mark as read',
              child: IconButton(
                icon: const Icon(Icons.mark_email_read_outlined, size: 16),
                color: AppColors.neutral400,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: onMarkRead,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type.toLowerCase()) {
      String t when t.contains('appointment') => ('Appointment', AppColors.primary),
      String t when t.contains('queue') => ('Queue', AppColors.info),
      String t when t.contains('medication') => ('Medication', AppColors.success),
      String t when t.contains('prediction') || t.contains('health') => ('Health', const Color(0xFF6D28D9)),
      String t when t.contains('payment') => ('Payment', AppColors.warning),
      String t when t.contains('video') => ('Video', AppColors.info),
      _ => (type.isEmpty ? 'System' : type, AppColors.neutral600),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ChannelBadge extends StatelessWidget {
  final String channel;
  const _ChannelBadge({required this.channel});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (channel.toLowerCase()) {
      'sms' => (Icons.sms_outlined, 'SMS'),
      'fcm' || 'push' => (Icons.notifications_outlined, 'Push'),
      'email' => (Icons.email_outlined, 'Email'),
      'inapp' || 'in-app' => (Icons.inbox_outlined, 'In-App'),
      _ => (Icons.send_outlined, channel.isEmpty ? '—' : channel),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.neutral400),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.neutral400, fontSize: 10),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status.toLowerCase()) {
      'sent' || 'delivered' => ('Sent', AppColors.success),
      'failed' => ('Failed', AppColors.danger),
      'pending' => ('Pending', AppColors.warning),
      _ => (status.isEmpty ? '—' : status, AppColors.neutral400),
    };
    return Text(
      label,
      style: AppTypography.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
    );
  }
}
