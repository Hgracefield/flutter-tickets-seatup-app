import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/chat_message.dart';
import 'package:seatup_app/vm/storage_provider.dart';
import 'package:seatup_app/vm/user_chat_notifier.dart';

class UserToUserChat extends ConsumerStatefulWidget {
  const UserToUserChat({
    super.key,
    required this.postId,
    required this.partnerId,
    required this.sellerId,
  });

  final String postId;    // ✅ 거래(게시글) id
  final String partnerId; // ✅ 상대 userId
  final String sellerId;  // ✅ 이 거래의 판매자 userId

  @override
  ConsumerState<UserToUserChat> createState() => _UserToUserChatState();
}

class _UserToUserChatState extends ConsumerState<UserToUserChat> {
  late final TextEditingController _controller;

  late final String myId;      // 로그인 user_id
  late final String partnerId; // 상대
  late final String roomID;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // GetStorage에서 내 id 읽기
    final raw = ref.read(storageProvider).read('user_id');
    // myId = raw.toString();
    myId = raw?.toString() ?? '';

    partnerId = widget.partnerId;

    // 내 id와 상대 id 같으면 에러
    if (partnerId == myId) {
      throw Exception('partnerId == myId (상대가 나 자신입니다)');
    }

    roomID = ref.read(chatNotifierProvider.notifier)
        .makeRoomId(widget.postId, myId, partnerId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _iAmSeller => myId == widget.sellerId;

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatMessagesProvider(roomID));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        ),
        title: Column(
          children: [
            const Text(
              "티켓 거래 채팅",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'postId: ${widget.postId} / 상대: $partnerId',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text("첫 메시지를 보내보세요 🙂"));
                }
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (_, index) => buildItem(context, messages[index], myId),
                );
              },
              error: (error, _) => Center(child: Text('오류 : $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),

          // 입력창
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "메시지를 입력하세요...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    // ✅ buyerId / sellerId 정리
                    final sellerId = widget.sellerId;
                    final buyerId = _iAmSeller ? partnerId : myId;

                    await ref.read(chatNotifierProvider.notifier).sendMessage(
                      roomId: roomID,
                      postId: widget.postId,
                      senderId: myId,
                      partnerId: partnerId,
                      text: text,
                      sellerId: sellerId,
                      buyerId: buyerId,
                    );

                    _controller.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(80, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('전송', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, ChatMessage message, String myId) {
    final isMe = message.senderId == myId;
    final time = TimeOfDay.fromDateTime(message.createdAt).format(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? Colors.black : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 20),
              ),
              border: isMe ? null : Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
        ],
      ),
    );
  }
}
