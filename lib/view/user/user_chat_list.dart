import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/vm/storage_provider.dart';
import 'package:seatup_app/vm/user_chat_notifier.dart';
import 'package:seatup_app/view/user/user_to_user_chat.dart';

class UserChatList extends ConsumerWidget {
  const UserChatList({super.key});

  Future<void> _openNewChatDialog(BuildContext context, WidgetRef ref, String myId) async {
    final postIdCtrl = TextEditingController();
    final partnerIdCtrl = TextEditingController();
    final sellerIdCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('새 채팅 열기(테스트용)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: postIdCtrl,
              decoration: const InputDecoration(labelText: 'postId (예: 100)'),
            ),
            TextField(
              controller: partnerIdCtrl,
              decoration: const InputDecoration(labelText: 'partnerId (상대 user_id)'),
            ),
            TextField(
              controller: sellerIdCtrl,
              decoration: const InputDecoration(labelText: 'sellerId (판매자 user_id)'),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 실제 서비스에서는 게시글/거래 화면에서 자동으로 넘어와야 해요.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('열기'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final postId = postIdCtrl.text.trim();
    final partnerId = partnerIdCtrl.text.trim();
    final sellerId = sellerIdCtrl.text.trim();

    if (postId.isEmpty || partnerId.isEmpty || sellerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('postId/partnerId/sellerId를 모두 입력하세요')),
      );
      return;
    }

    if (partnerId == myId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('partnerId는 내 id와 같을 수 없어요')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserToUserChat(
          postId: postId,
          partnerId: partnerId,
          sellerId: sellerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raw = ref.read(storageProvider).read('user_id');
    final myId = raw?.toString() ?? '';

    if (myId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('로그인 정보(user_id)가 없습니다.')),
      );
    }

    final roomsAsync = ref.watch(chatRoomsProvider(myId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        centerTitle: true,

        // ✅ 앱바 채팅(+) 버튼 추가
        actions: [
          IconButton(
            tooltip: '새 채팅(테스트용)',
            onPressed: () => _openNewChatDialog(context, ref, myId),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
        ],
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (snapshot) {
          final docs = snapshot.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('채팅방이 없습니다.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              // ✅ members
              final members = (data['members'] as List? ?? [])
                  .map((e) => e.toString())
                  .toList();

              // ✅ 상대 id 계산
              String partnerId = '';
              try {
                partnerId = members.firstWhere((id) => id != myId);
              } catch (_) {
                return const SizedBox.shrink();
              }

              // ✅ 거래 정보
              final postId = (data['postId'] ?? '').toString();
              final sellerId = (data['sellerId'] ?? '').toString();

              // ✅ 마지막 메시지/시간
              final lastMessage = (data['lastMessage'] ?? '').toString();
              final ts = data['lastMessageAt'];
              final lastAt = ts is Timestamp ? ts.toDate().toLocal() : null;

              void openChat() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserToUserChat(
                      postId: postId,
                      partnerId: partnerId,
                      sellerId: sellerId,
                    ),
                  ),
                );
              }

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    partnerId,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                title: Text('상대 ID: $partnerId  (post: $postId)'),
                subtitle: Text(
                  lastMessage.isEmpty ? '대화를 시작해보세요' : lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lastAt == null
                          ? ''
                          : TimeOfDay.fromDateTime(lastAt).format(context),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),

                    // ✅ 리스트 아이템 채팅 버튼 추가
                    IconButton(
                      tooltip: '채팅 열기',
                      onPressed: openChat,
                      icon: const Icon(Icons.chat),
                    ),
                  ],
                ),
                onTap: openChat, // ✅ 탭해도 열림
              );
            },
          );
        },
      ),
    );
  }
}
