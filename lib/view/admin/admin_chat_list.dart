import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/vm/chat_provider.dart';
import 'package:seatup_app/vm/storage_provider.dart';

import 'admin_chat_detail.dart';

class AdminChatList extends ConsumerStatefulWidget {
  const AdminChatList({super.key});

  @override
  ConsumerState<AdminChatList> createState() => _AdminChatListState();
}

class _AdminChatListState extends ConsumerState<AdminChatList> {
  void _openDetail(String userId) {
    // 선택된 userId 저장
    ref.read(adminSelectedUserIdProvider.notifier).state = userId;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminChatDetail()),
    );
  }

  Future<void> _assignStaff({
    required String userId,
    required String staffId,
  }) async {
    await ref
        .read(chatRepoProvider)
        .assignStaff(userId: userId, staffId: staffId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(" $userId 고객을 $staffId 로 배정 완료")),
    );
  }

  @override
  Widget build(BuildContext context) {
    //  GetStorage에서 staff_seq 가져오기
    final box = ref.read(storageProvider);
    final staffId = box
        .read('staff_seq')
        ?.toString(); // int일 수도 있어서 toString()

    //  staff 로그인 정보 없으면 막기
    if (staffId == null || staffId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("직원 로그인 정보가 없습니다.\n다시 로그인해주세요.")),
      );
    }

    final emptyRoomsAsync = ref.watch(adminEmptyRoomsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("관리자 채팅 (staff_seq: $staffId)"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "미배정"),
              Tab(text: "내 담당"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            //  1) 미배정 채팅방
            emptyRoomsAsync.when(
              data: (snapshot) {
                final docs = snapshot.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("미배정 채팅방이 없습니다."));
                }

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final userId = doc.id;

                    final startAt = (data["startAt"] ?? "")
                        .toString();
                    final dialog = (data["dialog"] as List?) ?? [];

                    String lastMsg = "";
                    if (dialog.isNotEmpty) {
                      final last = dialog.last;
                      if (last is Map) {
                        lastMsg = (last["message"] ?? "").toString();
                      }
                    }

                    return ListTile(
                      title: Text("고객: $userId"),
                      subtitle: Text(
                        "시작일: $startAt\n마지막내용: $lastMsg",
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(
                            onPressed: () => _assignStaff(
                              userId: userId,
                              staffId: staffId,
                            ),
                            child: const Text("배정"),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _openDetail(userId),
                            icon: const Icon(Icons.chat),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("에러: $e")),
            ),

            // 2) 내 담당 채팅방 (입력 필요 X)
            _MyRoomsList(staffId: staffId, onOpen: _openDetail),
          ],
        ),
      ),
    );
  }
}

class _MyRoomsList extends ConsumerWidget {
  const _MyRoomsList({required this.staffId, required this.onOpen});

  final String staffId;
  final void Function(String userId) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRoomsAsync = ref.watch(adminMyRoomsProvider(staffId));

    return myRoomsAsync.when(
      data: (snapshot) {
        final docs = snapshot.docs;

        if (docs.isEmpty) {
          return Center(
            child: Text("담당 중인 채팅방이 없습니다. (staffId: $staffId)"),
          );
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final userId = doc.id;

            final startAt = (data["startAt"] ?? "").toString();
            final dialog = (data["dialog"] as List?) ?? [];

            String lastMsg = "";
            if (dialog.isNotEmpty) {
              final last = dialog.last;
              if (last is Map) {
                lastMsg = (last["message"] ?? "").toString();
              }
            }

            return ListTile(
              title: Text("고객: $userId"),
              subtitle: Text("시작일: $startAt\n마지막: $lastMsg"),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => onOpen(userId),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("에러: $e")),
    );
  }
}
