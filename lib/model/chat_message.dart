import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage{
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage(
    {
      required this.id,
      required this.senderId,
      required this.text,
      required this.createdAt,
      required this.isRead
    }
  );

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id){
    final ts = map['createdAt'];
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? "",
      text: map['text'] ?? '',
      createdAt: ts is Timestamp ? ts.toDate().toLocal() : DateTime.now(),   // Firestore 전용 Timestamp
      isRead: map['isRead'] ?? false
    );
  }
}