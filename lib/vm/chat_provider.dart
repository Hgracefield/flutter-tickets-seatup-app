import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Firestore 인스턴스를 Provider로 관리
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// 채팅 관련 Firestore 로직을 모아둔 Repository
class ChatRepository {
  ChatRepository(this.db);
  final FirebaseFirestore db;

  // chatting/{userId} 문서가 없으면 만들어줌 (update 에러 방지)
  Future<void> ensureRoom(String userId) async {
    try {
      final roomRef = db.collection("chatting").doc(userId);

      debugPrint("🔥 ensureRoom 시작 userId=$userId");

      final snap = await roomRef.get();
      debugPrint("🔥 ensureRoom get 완료 exists=${snap.exists}");

      if (!snap.exists) {
        await roomRef.set({
          "employeeId": "empty",
          "startAt": DateTime.now().toString().substring(0, 10),
          "dialog": <Map<String, dynamic>>[],
        });

        debugPrint("chatting/$userId 생성 성공");
      } else {
        debugPrint(" chatting/$userId 이미 있음");
      }
    } catch (e) {
      debugPrint(" ensureRoom 실패: $e");
      rethrow;
    }
  }

  // 채팅방 실시간 감시 스트림
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchRoom(
    String userId,
  ) {
    return db.collection("chatting").doc(userId).snapshots();
  }

  // 메시지 전송
  // talker = "user" or "staff"
  Future<void> sendMessage({
    required String userId,
    required String talker,
    required String message,
  }) async {
    await ensureRoom(userId);

    final ref = db.collection("chatting").doc(userId);
    await ref.update({
      "dialog": FieldValue.arrayUnion([
        {
          "date": DateTime.now().toString(),
          "message": message.trim(),
          "talker": talker,
        },
      ]),
    });
  }

  //  관리자용 기능 추가

  // 직원이 담당 중인 채팅방들만 가져오기
  Stream<QuerySnapshot<Map<String, dynamic>>> watchRoomsByStaff(
    String staffId,
  ) {
    return db
        .collection("chatting")
        .where("employeeId", isEqualTo: staffId)
        .snapshots();
  }

  // 담당자 없는 채팅방들만 가져오기 (empty)
  Stream<QuerySnapshot<Map<String, dynamic>>> watchRoomsEmpty() {
    return db
        .collection("chatting")
        .where("employeeId", isEqualTo: "empty")
        .snapshots();
  }

  // 담당자 없는 고객을 "내 staffId"로 배정하기
  Future<void> assignStaff({
    required String userId,
    required String staffId,
  }) async {
    final ref = db.collection("chatting").doc(userId);

    await ref.set({"employeeId": staffId}, SetOptions(merge: true));
  }
}

/// Repository Provider
final chatRepoProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(firestoreProvider));
});

// 채팅방 문서 초기화 Provider
final chatRoomInitProvider = FutureProvider.family<void, String>((
  ref,
  userId,
) async {
  await ref.read(chatRepoProvider).ensureRoom(userId);
});

//  채팅방 실시간 스트림 Provider
final chatRoomProvider =
    StreamProvider.family<
      DocumentSnapshot<Map<String, dynamic>>,
      String
    >((ref, userId) {
      return ref.watch(chatRepoProvider).watchRoom(userId);
    });

//  관리자: 담당 중인 채팅방 리스트 스트림 Provider
final adminMyRoomsProvider =
    StreamProvider.family<
      QuerySnapshot<Map<String, dynamic>>,
      String
    >((ref, staffId) {
      return ref.watch(chatRepoProvider).watchRoomsByStaff(staffId);
    });

//  관리자: 미배정(empty) 채팅방 리스트 스트림 Provider
final adminEmptyRoomsProvider =
    StreamProvider<QuerySnapshot<Map<String, dynamic>>>((ref) {
      return ref.watch(chatRepoProvider).watchRoomsEmpty();
    });

// 관리자 화면에서 "선택된 유저Id" 저장하는 Provider
//  - 예: 관리자 리스트에서 고객 클릭하면 userId 저장
final adminSelectedUserIdProvider = StateProvider<String?>(
  (ref) => null,
);
