import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/chat_message.dart';

/*
  user랑 chat하는 notifier
*/

// 연결하는 부분
final chatMessagesCollectionProvider =
    Provider.family<CollectionReference, String>((ref, roomId) {
  return FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(roomId)
      .collection('messages');
});


// 데이터 가져와서 보여주는곳
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, roomId) {
  final col = ref.watch(chatMessagesCollectionProvider(roomId));

  return col
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) =>
            ChatMessage.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  });
});


class UserChatNotifier extends Notifier<void> {
  @override
  void build() {}

  CollectionReference  _message(String roomId) => ref.read(chatMessagesCollectionProvider(roomId));

  Future<void> sendMessage(String roomId, String senderId, String text) async {
    await _message(roomId).add(
      {
        'senderId' : senderId,
        'text' : text,
        'createdAt' : FieldValue.serverTimestamp(),     // 서버에서사용하는 시간
        'isRead' : false
      }
    );
  }

  Future<void> deleteMessage(String roomId, String messageId) async{
    await _message(roomId).doc(messageId).delete();
  }

}
final chatNotifierProvider = NotifierProvider<UserChatNotifier,void>(
  UserChatNotifier.new  
);