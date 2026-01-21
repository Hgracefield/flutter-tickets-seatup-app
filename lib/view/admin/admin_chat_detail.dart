import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_side_bar.dart';
import 'package:seatup_app/vm/chat_provider.dart';

class AdminChatDetail extends ConsumerStatefulWidget {
  const AdminChatDetail({super.key, this.userId});

  // optional (없어도 됨)
  final String? userId;

  @override
  ConsumerState<AdminChatDetail> createState() =>
      _AdminChatDetailState();
}

class _AdminChatDetailState extends ConsumerState<AdminChatDetail> {
  final TextEditingController _msgController =
      TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _send(String userId) async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    await ref
        .read(chatRepoProvider)
        .sendMessage(userId: userId, talker: "staff", message: text);

    _msgController.clear();
  }

  String _formatDateTime(dynamic raw) {
    if (raw == null) return "";

    final s = raw.toString();
    if (s.length >= 19) return s.substring(0, 19);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    // userId가 없으면 provider에 저장된 선택값 사용
    final selectedUserId =
        widget.userId ?? ref.watch(adminSelectedUserIdProvider);

    if (selectedUserId == null || selectedUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("채팅 상세")),
        body: const Center(child: Text("고객을 먼저 선택해주세요!")),
      );
    }

    final roomAsync = ref.watch(chatRoomProvider(selectedUserId));

    return Scaffold(
      appBar: AppBar(title: Text("고객: $selectedUserId")),
      body: SafeArea(
        child: Column(
          children: [
            AdminSideBar (selectedMenu: SideMenu.chatlist, onMenuSelected: (menu) {}),
            Expanded(
              child: roomAsync.when(
                data: (snap) {
                  final data = snap.data() ?? {};
                  final dialog = (data["dialog"] as List?) ?? [];
                  final employeeId = (data["employeeId"] ?? "")
                      .toString();
                  final startAt = (data["startAt"] ?? "").toString();
        
                  return Column(
                    children: [
                      // 상단 정보
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "담당자: $employeeId   |   시작일: $startAt",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
        
                      // 채팅 내용
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: dialog.length,
                          itemBuilder: (context, index) {
                            final item = dialog[index];
        
                            if (item is! Map) return const SizedBox();
        
                            final talker = (item["talker"] ?? "")
                                .toString();
                            final message = (item["message"] ?? "")
                                .toString();
        
                            final isStaff = talker == "staff";
        
                            final timeLabel = _formatDateTime(
                              item["date"],
                            );
        
                            return Align(
                              alignment: isStaff
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    constraints: const BoxConstraints(
                                      maxWidth: 280,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isStaff
                                          ? Colors.blue.shade100
                                          : Colors.grey.shade200,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(message),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 6,
                                      right: 6,
                                      bottom: 4,
                                    ),
                                    child: Text(
                                      timeLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("에러: $e")),
              ),
            ),
        
            // 입력창
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        decoration: const InputDecoration(
                          hintText: "메시지 입력",
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _send(selectedUserId),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _send(selectedUserId),
                      child: const Text("전송"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
