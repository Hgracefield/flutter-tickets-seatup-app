import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/vm/chat_provider.dart';
import 'package:seatup_app/vm/storage_provider.dart';

class SellerToAdminChat extends ConsumerStatefulWidget {
  const SellerToAdminChat({super.key});

  @override
  ConsumerState<SellerToAdminChat> createState() =>
      _SellerToAdminChatState();
}

class _SellerToAdminChatState
    extends ConsumerState<SellerToAdminChat> {
  late final TextEditingController _controller;

  String? _ensuredUserId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String userId) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    try {
      await ref
          .read(chatRepoProvider)
          .sendMessage(userId: userId, talker: "user", message: text);

          ref.invalidate(chatRoomProvider(userId)); // 메세지 보낸뒤 새로고침
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("메시지 전송 실패: $e")));
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final box = ref.read(storageProvider);

    final userId = box.read('user_id')?.toString() ?? "0";
    final userName = box.read('user_name')?.toString() ?? "";

    if (userId == "0") {
      return const Scaffold(
        body: Center(child: Text("로그인 정보가 없습니다.")),
      );
    }

    //  userId 기준으로 딱 1번만 ensureRoom 실행
    if (_ensuredUserId != userId) {
      _ensuredUserId = userId;

      Future.microtask(() async {
        try {
          await ref.read(chatRepoProvider).ensureRoom(userId);
        } catch (e) {
          debugPrint(" ensureRoom 실패: $e");
        }
      });
    }

    String _formatDateTime(dynamic raw) {
      if (raw == null) return "";

      final s = raw.toString();
      if (s.length >= 19) return s.substring(0, 19);
      return s;
    }
    

    final roomAsync = ref.watch(chatRoomProvider(userId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "채팅 상담",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: roomAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("채팅 불러오기 실패: $e")),
              data: (doc) {
                final data = doc.data();
                final dialogs =
                    (data?["dialog"] as List?)?.cast<dynamic>() ?? [];

                if (dialogs.isEmpty) {
                  return const Center(
                    child: Text(
                      "상담을 시작해보세요 🙂",
                      style: TextStyle(color: Colors.black45),
                    ),
                  );
                }

                final reversed = dialogs.reversed.toList();

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  itemCount: reversed.length,
                  itemBuilder: (context, index) {
                    final raw = reversed[index];
                    if (raw is! Map) return const SizedBox();
                    final d = Map<String, dynamic>.from(raw);

                    final timeText = _formatDateTime(d["date"]);
                    return _ChatBubble(messageMap: d, timeText: timeText);
                  },
                );
              },
            ),
          ),

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _sendMessage(userId),
                        decoration: const InputDecoration(
                          hintText: "메시지를 입력하세요",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => _sendMessage(userId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                      ),
                      child: const Text(
                        "보내기",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
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

class _ChatBubble extends StatelessWidget {
  final Map<String, dynamic> messageMap;
  final String timeText;
  const _ChatBubble({
   required this.messageMap,
   required this.timeText});

  @override
  Widget build(BuildContext context) {
    final talker = (messageMap["talker"] ?? "").toString();
    final msg = (messageMap["message"] ?? "").toString();
    final isMe = talker == "user";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.black : const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 2),
                bottomRight: Radius.circular(isMe ? 2 : 16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  msg,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : Colors.black45
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
