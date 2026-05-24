import '../../domain/entities/platform_notification.dart';

class PlatformNotificationModel extends PlatformNotification {
  const PlatformNotificationModel({
    super.id,
    super.notificationType,
    super.channel,
    super.title,
    super.body,
    super.status,
    required super.sentAt,
    super.isRead,
  });

  factory PlatformNotificationModel.fromJson(Map<String, dynamic> j) => PlatformNotificationModel(
        id: (j['id'] as String?) ?? '',
        notificationType: (j['notificationType'] as String?) ?? '',
        channel: (j['channel'] as String?) ?? '',
        title: j['title'] as String?,
        body: (j['body'] as String?) ?? '',
        status: (j['status'] as String?) ?? '',
        sentAt: DateTime.tryParse((j['sentAt'] as String?) ?? '') ?? DateTime.now(),
        isRead: (j['isRead'] as bool?) ?? false,
      );
}
