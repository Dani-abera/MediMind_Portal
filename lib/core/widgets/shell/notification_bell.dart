import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class NotificationBell extends StatelessWidget {
  final int unreadCount;
  final List<Map<String, dynamic>> notifications;
  final String viewAllRoute;

  const NotificationBell({
    super.key,
    required this.unreadCount,
    this.notifications = const [],
    required this.viewAllRoute,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 44),
      tooltip: '',
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 360),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: FaIcon(FontAwesomeIcons.bell, size: 16, color: AppColors.neutral500),
          ),
          if (unreadCount > 0)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: AppTypography.caption
                      .copyWith(color: Colors.white, fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      itemBuilder: (ctx) => notifications.isEmpty
          ? [
              PopupMenuItem(
                enabled: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No new notifications',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.neutral400),
                    ),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'view_all',
                child: Center(
                  child: Text(
                    'View all notifications',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ]
          : [
              ...notifications.take(10).map(
                    (n) => PopupMenuItem(
                      enabled: false,
                      child: _NotificationItem(data: n),
                    ),
                  ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'view_all',
                child: Center(
                  child: Text(
                    'View all',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ],
      onSelected: (v) {
        if (v == 'view_all') context.go(viewAllRoute);
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const _NotificationItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5, right: 8),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['title']?.toString() ?? 'Notification',
                style: AppTypography.bodySmall
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (data['body'] != null)
                Text(
                  data['body'].toString(),
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
