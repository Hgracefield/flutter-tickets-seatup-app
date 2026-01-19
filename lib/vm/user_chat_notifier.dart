import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/chat_message.dart';

// messages 컬렉션
final chatMessagesCollectionProvider =
    Provider.family<CollectionReference<Map<String, dynamic>>, String>((ref, roomId) {
  return FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(roomId)
      .collection('messages');
});

// room 문서
final chatRoomDocProvider =
    Provider.family<DocumentReference<Map<String, dynamic>>, String>((ref, roomId) {
  return FirebaseFirestore.instance.collection('chat_rooms').doc(roomId);
});

// 내 채팅방 리스트 (members에 내 id가 들어간 방만)
// Firestore: chat_rooms 문서에 members: ["2","4"] 형태로 저장되어 있어야 함
final chatRoomsProvider =
    StreamProvider.family<QuerySnapshot<Map<String, dynamic>>, String>((ref, myId) {
  return FirebaseFirestore.instance
      .collection('chat_rooms')
      .where('members', arrayContains: myId)
      .orderBy('lastMessageAt', descending: true)
      .snapshots();
});


// 메시지 스트림
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, roomId) {
  final col = ref.watch(chatMessagesCollectionProvider(roomId));

  return col
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data(), doc.id)).toList();
  });
});

class UserChatNotifier extends Notifier<void> {
  @override
  void build() {}

  DocumentReference<Map<String, dynamic>> _roomRef(String roomId) =>
      ref.read(chatRoomDocProvider(roomId));

  CollectionReference<Map<String, dynamic>> _messageRef(String roomId) =>
      ref.read(chatMessagesCollectionProvider(roomId));

  /// 거래(게시글) 기준 방 id
  /// 예: postId=100, a=2, b=4  ->  "100_2_4"
  String makeRoomId(String postId, String a, String b) {
    final ids = [a, b]..sort();
    return '${postId}_${ids.join('_')}';
  }

  Future<void> sendMessage({
    required String roomId,
    required String postId,
    required String senderId,
    required String partnerId,
    required String text,

    // (선택) 거래앱이면 방 문서에 역할 저장하면 나중에 리스트/관리 편함
    required String sellerId,
    required String buyerId,
  }) async {
    final roomRef = _roomRef(roomId);

    // 방 문서 생성/업데이트
    await roomRef.set({
      'postId': postId,
      'members': [senderId, partnerId],
      'sellerId': sellerId,
      'buyerId': buyerId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 메시지 추가
    await _messageRef(roomId).add({
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // 채팅방 리스트용 최신 정보
    await roomRef.set({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    }, SetOptions(merge: true));
  }

  Future<void> deleteMessage(String roomId, String messageId) async {
    await _messageRef(roomId).doc(messageId).delete();
  }

  Future<String> openOrCreateRoom({
  required String postId,
  required String myId,
  required String sellerId,
}) async {
  if (myId == sellerId) {
    throw Exception('내가 내 게시글에 채팅할 수는 없어요');
  }

  final roomId = makeRoomId(postId, myId, sellerId);
  final roomRef = _roomRef(roomId);

  final snap = await roomRef.get();

  if (!snap.exists) {
    await roomRef.set({
      'postId': postId,
      'members': [myId, sellerId],  // ✅ 여기서 members 저장!
      'sellerId': sellerId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  return roomId;
}



}

final chatNotifierProvider = NotifierProvider<UserChatNotifier, void>(
  UserChatNotifier.new,
);
