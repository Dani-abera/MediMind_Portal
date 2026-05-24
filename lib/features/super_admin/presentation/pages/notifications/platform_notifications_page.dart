import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../domain/entities/platform_notification.dart';
import '../../bloc/notifications/platform_notifications_bloc.dart';

class PlatformNotificationsPage extends StatelessWidget {
  const PlatformNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlatformNotificationsBloc>()..add(const PlatformNotificationsStarted()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlatformNotificationsBloc, PlatformNotificationsState>(
      listener: (ctx, state) {
        if (state is PlatformNotificationsActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is PlatformNotificationsActionError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Notifications',
            subtitle: 'Platform alerts and activity notifications',
            actions: [
              BlocBuilder<PlatformNotificationsBloc, PlatformNotificationsState>(
                builder: (ctx, state) {
                  final hasUnread = state is PlatformNotificationsLoaded &&
                      state.items.any((n) => !n.isRead);
                  return TextButton.icon(
                    onPressed: hasUnread
                        ? () => ctx
                            .read<PlatformNotificationsBloc>()
                            .add(const PlatformNotificationsMarkAllReadRequested())
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
                    .read<PlatformNotificationsBloc>()
                    .add(const PlatformNotificationsRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<PlatformNotificationsBloc, PlatformNotificationsState>(
              builder: (ctx, state) {
                final items = state is PlatformNotificationsLoaded ? state.items : <PlatformNotification>[];
                final total = state is PlatformNotificationsLoaded ? state.total : 0;
                final page = state is PlatformNotificationsLoaded ? state.page : 1;
                const pageSize = 20;
                final isLoading = state is PlatformNotificationsLoading;

                return AppDataTable<PlatformNotification>(
                  rows: items,
                  isLoading: isLoading,
                  selectable: false,
                  emptyMessage: 'No notifications',
                  pagination: PaginationConfig(
                    page: page,
                    pageSize: pageSize,
                    total: total,
                    onPageChanged: (p) => ctx
                        .read<PlatformNotificationsBloc>()
                        .add(PlatformNotificationsPageChanged(p)),
                    onPageSizeChanged: (_) {},
                  ),
                  columns: [
                    DataTableColumn(
                      label: '',
                      width: 6,
                      builder: (n) => n.isRead
                          ? const SizedBox.shrink()
                          : Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                    DataTableColumn(
                      label: 'Type',
                      width: 160,
                      builder: (n) => _TypeBadge(type: n.notificationType),
                    ),
                    DataTableColumn(
                      label: 'Message',
                      builder: (n) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (n.title != null && n.title!.isNotEmpty)
                            Text(
                              n.title!,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            n.body,
                            style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    DataTableColumn(
                      label: 'Channel',
                      width: 90,
                      builder: (n) => _ChannelBadge(channel: n.channel),
                    ),
                    DataTableColumn(
                      label: 'Status',
                      width: 80,
                      builder: (n) => _StatusBadge(status: n.status),
                    ),
                    DataTableColumn(
                      label: 'Time',
                      width: 130,
                      builder: (n) => Text(
                        DateFormat('MMM d, HH:mm').format(n.sentAt),
                        style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                      ),
                    ),
                    DataTableColumn(
                      label: '',
                      width: 40,
                      builder: (n) => n.isRead
                          ? const SizedBox.shrink()
                          : Tooltip(
                              message: 'Mark as read',
                              child: IconButton(
                                icon: const Icon(Icons.mark_email_read_outlined, size: 16),
                                color: AppColors.neutral500,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => ctx
                                    .read<PlatformNotificationsBloc>()
                                    .add(PlatformNotificationMarkReadRequested(n.id)),
                              ),
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

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type.toLowerCase()) {
      String t when t.contains('appointment') => ('Appointment', AppColors.primary),
      String t when t.contains('subscription') => ('Subscription', AppColors.warning),
      String t when t.contains('center') => ('Center', AppColors.info),
      String t when t.contains('doctor') => ('Doctor', const Color(0xFF6D28D9)),
      String t when t.contains('payment') => ('Payment', AppColors.success),
      String t when t.contains('alert') => ('Alert', AppColors.danger),
      _ => (type.isEmpty ? 'System' : type, AppColors.neutral600),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
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
        Icon(icon, size: 12, color: AppColors.neutral500),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
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
      _ => (status.isEmpty ? '—' : status, AppColors.neutral500),
    };
    return Text(
      label,
      style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}
