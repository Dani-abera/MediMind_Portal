import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String senderType;
  final String content;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    required this.sentAt,
  });

  bool get isFromDoctor => senderType.toLowerCase() == 'doctor';

  @override
  List<Object?> get props =>
      [id, senderId, senderName, senderType, content, sentAt];
}
