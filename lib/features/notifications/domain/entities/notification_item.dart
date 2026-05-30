import 'package:equatable/equatable.dart';

class NotificationItem extends Equatable {
  final String id;
  final String notificationType;
  final String channel;
  final String? title;
  final String body;
  final String status;
  final DateTime sentAt;
  final bool isRead;

  const NotificationItem({
    this.id = '',
    this.notificationType = '',
    this.channel = '',
    this.title,
    this.body = '',
    this.status = '',
    required this.sentAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, notificationType, channel, title, body, status, sentAt, isRead];
}
