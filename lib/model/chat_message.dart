import 'dart:convert';

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
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? "",
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate() ,   // Firestore 전용 Timestamp
      isRead: map['isRead'] ?? false
    );
  }
}