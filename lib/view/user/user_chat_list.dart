import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/vm/storage_provider.dart';
import 'package:seatup_app/vm/user_chat_notifier.dart';
import 'package:seatup_app/view/user/user_to_user_chat.dart';

class UserChatList extends ConsumerWidget {
  const UserChatList({super.key});

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('채팅'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.withOpacity(0.15)),
        ),
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
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              // members
              final members = (data['members'] as List? ?? [])
                  .map((e) => e.toString())
                  .toList();

              // 상대 id 계산
              String partnerId = '';
              try {
                partnerId = members.firstWhere((id) => id != myId);
              } catch (_) {
                return const SizedBox.shrink();
              }

              // 거래 정보
              final postId = (data['postId'] ?? '').toString();

              // 마지막 메시지/시간
              final lastMessage = (data['lastMessage'] ?? '').toString();
              final ts = data['lastMessageAt'];
              final lastAt = ts is Timestamp ? ts.toDate().toLocal() : null;

              // 아바타에 표시할 짧은 텍스트(너무 길면 UI 깨짐 방지)
              final avatarText = partnerId.length >= 2
                  ? partnerId.substring(0, 2)
                  : partnerId;

              void openChat() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserToUserChat(
                      postId: postId,
                      partnerId: partnerId,
                    ),
                  ),
                );
              }

              return InkWell(
                onTap: openChat,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // 프로필(임시)
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFF1F3F5),
                        child: Text(
                          avatarText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 가운데 텍스트 영역
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1줄: 상대 + post 라벨
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '상대 ID: $partnerId',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (postId.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F3F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'post $postId',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // 2줄: 마지막 메시지
                            Text(
                              lastMessage.isEmpty
                                  ? '대화를 시작해보세요'
                                  : lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // 오른쪽 시간 영역
                      Text(
                        lastAt == null
                            ? ''
                            : TimeOfDay.fromDateTime(lastAt).format(context),
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
