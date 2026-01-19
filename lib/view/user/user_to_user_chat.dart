import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:seatup_app/model/chat_message.dart';
import 'package:seatup_app/vm/storage_provider.dart';
import 'package:seatup_app/vm/user_chat_notifier.dart';

// ================================================================
// ✅ Firestore 경로 Provider (messages는 roomId별로 달라서 family 사용)
// ================================================================

/// 🔥 (바꿀 수 있음) 채팅방 컬렉션 이름
const String kChatRoomsCollection = 'chat_rooms';

/// roomId의 messages 컬렉션
final chatMessagesCollectionProvider =
    Provider.family<CollectionReference<Map<String, dynamic>>, String>((ref, roomId) {
  return FirebaseFirestore.instance
      .collection(kChatRoomsCollection)
      .doc(roomId)
      .collection('messages');
});

/// roomId별 메시지 스트림
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, roomId) {
  final col = ref.watch(chatMessagesCollectionProvider(roomId));

  return col
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList());
});

/// ✅ UserChatNotifier Provider (너 파일에 이미 있다고 가정)
/// - sendMessage(roomId, partnerId, text)
/// - deleteMessage(roomId, messageId)
/// 위 2개 메서드가 user_chat_notifier.dart 안에 있어야 함
final chatNotifierProvider = NotifierProvider<UserChatNotifier, void>(
  UserChatNotifier.new,
);

// ================================================================
// ✅ UI: class 이름 고정
// ================================================================

class UserToUserChat extends ConsumerStatefulWidget {
  const UserToUserChat({
    super.key,
    required this.roomId,
    required this.partnerName,
    required this.partnerId,
  });

  final String roomId;
  final String partnerName;
  final String partnerId;

  @override
  ConsumerState<UserToUserChat> createState() => _UserToUserChatState();
}

class _UserToUserChatState extends ConsumerState<UserToUserChat> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // ✅ 내 id (GetStorage)
    final myId = ref.read(storageProvider).read('user_id')?.toString();
    if (myId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 정보가 없습니다.')),
      );
      return;
    }

    _textController.clear();

    // ✅ 메시지 전송 (너의 notifier 함수 시그니처에 맞춤)
    await ref.read(chatNotifierProvider.notifier).sendMessage(
          widget.roomId,
          widget.partnerId, // 상대 id (필요없다면 notifier에서 제거해도 됨)
          text,
        );

    // 보내고 나서 아래로 스크롤
    await Future.delayed(const Duration(milliseconds: 80));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.read(storageProvider).read('user_id')?.toString();

    final messagesAsync = ref.watch(chatMessagesProvider(widget.roomId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partnerName),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: () => ref.invalidate(chatMessagesProvider(widget.roomId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // ---------------------- 메시지 영역 ----------------------
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('에러: $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('첫 메시지를 보내보세요 🙂'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];

                    // ✅ 내 메시지 여부
                    final isMe = (myId != null && m.senderId == myId);

                    return _ChatBubble(
                      message: m,
                      isMe: isMe,
                      onLongPress: () async {
                        // ✅ 삭제는 내 메시지만 허용
                        if (!isMe) return;

                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('메시지 삭제'),
                            content: const Text('이 메시지를 삭제할까요?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        );

                        if (ok == true) {
                          await ref
                              .read(chatNotifierProvider.notifier)
                              .deleteMessage(
                                widget.roomId,
                                m.id,
                              );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),

          // ---------------------- 입력 영역 ----------------------
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 46,
                    width: 46,
                    child: ElevatedButton(
                      onPressed: _send,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ✅ 채팅 말풍선 위젯 (시간 + 읽음 표시 포함)
// - ChatMessage 모델에 createdAt(DateTime), isRead(bool), text(String), senderId(String), id(String) 있어야 함
// ================================================================

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.onLongPress,
  });

  final ChatMessage message;
  final bool isMe;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(message.createdAt).format(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue.shade500 : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isMe ? 14 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 14),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // 메시지 내용
              Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),

              // 시간 + 읽음
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead
                          ? Colors.yellowAccent
                          : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
