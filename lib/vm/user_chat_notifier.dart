import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/chat_message.dart';
import 'package:seatup_app/vm/storage_provider.dart';

// 채팅방 안 메시지들을 가져오는 provider(메시지 보내기, 메시지 삭제, 메시지 수정가능)
final chatMessagesCollectionProvider =
    Provider.family<CollectionReference<Map<String, dynamic>>, String>((ref, roomId) {
      // return값이 Map<String, dynamic>으로 반환한다. , String -> 파라미터값
  return FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(roomId)
      .collection('messages');
});

// 메시지 스트림(읽기 + 실시간 UI용)
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


// 채팅방 자체를 가져오는 provider(방 정보, 읽음처리, 상태변경[open,closed], 그방의 타입)
final chatRoomDocProvider =
    Provider.family<DocumentReference<Map<String, dynamic>>, String>((ref, roomId) {
  return FirebaseFirestore.instance
                          .collection('chat_rooms')
                          .doc(roomId);
                          
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
    required String roomId,         // 방번호
    required String postId,         // 판매방번호
    required String senderId,       // 보내는사람번호(getstorage)
    required String partnerId,      // 채팅을 받는사람번호
    required String text,
  }) async {
    final roomRef = _roomRef(roomId);

    // 방 문서 생성/업데이트
    // 채팅방이없으면 만들고 있으면 필요한 필드만 갱신
    await roomRef.set({
      'postId': postId,
      'members': [senderId, partnerId],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));    // merge -> 없는 필드만 추가 / 변경가능

    // 메시지 추가
    await _messageRef(roomId).add({
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // 채팅방 리스트용 최신 정보 -> Firestore는 랜덤으로 리스트에 가져옴 따라서 필요
    await roomRef.set({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    }, SetOptions(merge: true));
  }

  // 처음방인지 아닌지 확인함수
  Future<String> openChat(String postId, String partnerId) async{
    final raw = ref.read(storageProvider).read('user_id');
    final myId = raw?.toString() ?? '';
    final roomId =makeRoomId(postId, myId, partnerId);
    final roomRef = ref.read(chatRoomDocProvider(roomId));
    final roomSnap = await roomRef.get();
    
    if (roomSnap.exists) {
      final data = roomSnap.data();
      final members = List<String>.from(data?['members'] ?? []);
      final partnerID = members.firstWhere((id) => id != myId, orElse: () => partnerId);  // 이게 중요한 포인트
      return partnerID;
    }else{
      return partnerId;
    }
  }


  // 읽었는지 아닌지 확인
  Future<void> markMessagesAsRead({
  required String roomId,
  required String myId,
}) async {
  final col = _messageRef(roomId);

  // 상대가 보낸, 아직 안 읽은 메시지들만 조회
  final snap = await col
      .where('isRead', isEqualTo: false)
      .where('senderId', isNotEqualTo: myId)
      .get();

  if (snap.docs.isEmpty) return;

  // 한번에 업데이트 (batch)
  final batch = FirebaseFirestore.instance.batch();
  for (final doc in snap.docs) {
    batch.update(doc.reference, {'isRead': true});
  }
  await batch.commit();
}


  Future<void> deleteMessage(String roomId, String messageId) async {
    await _messageRef(roomId).doc(messageId).delete();
  }
}

final chatNotifierProvider = NotifierProvider<UserChatNotifier, void>(
  UserChatNotifier.new,
);
