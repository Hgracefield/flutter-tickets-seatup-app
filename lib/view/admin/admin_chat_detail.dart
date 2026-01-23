import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_side_bar.dart';
import 'package:seatup_app/vm/chat_provider.dart';
import 'package:seatup_app/util/color.dart';

class AdminChatDetail extends ConsumerStatefulWidget {
  const AdminChatDetail({super.key, this.userId});

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
    return s.length >= 19 ? s.substring(0, 19) : s;
  }

  @override
  Widget build(BuildContext context) {
    final selectedUserId =
        widget.userId ?? ref.watch(adminSelectedUserIdProvider);

    if (selectedUserId == null || selectedUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("채팅 상세"),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: AppColors.textColor,
        ),
        body: const Center(child: Text("고객을 먼저 선택해주세요!")),
      );
    }

    final roomAsync = ref.watch(chatRoomProvider(selectedUserId));

    return Scaffold(
      backgroundColor: AppColors.adminBackgroundColor, //  배경
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: AppColors.textColor,
        title: Text(
          "고객: $selectedUserId",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.adminTitleColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            //  사이드바는 Row 왼쪽 고정
            AdminSideBar(
              selectedMenu: SideMenu.chatlist,
              onMenuSelected: (menu) {},
            ),

            //  오른쪽은 채팅 전체 화면
            Expanded(
              child: Column(
                children: [
                  //  채팅 내용
                  Expanded(
                    child: roomAsync.when(
                      data: (snap) {
                        if (!snap.exists) {
                          return const Center(
                            child: Text(
                              "채팅방이 존재하지 않습니다.",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColor,
                              ),
                            ),
                          );
                        }

                        final data = snap.data() ?? {};
                        final dialog =
                            (data["dialog"] as List?) ?? [];
                        final employeeId = (data["employeeId"] ?? "")
                            .toString();
                        final startAt = (data["startAt"] ?? "")
                            .toString();

                        return Column(
                          children: [
                            // 상단 정보
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "담당자: $employeeId   |   시작일: $startAt",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            AppColors.adminTitleColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.adminBorderColor,
                            ),

                            // 채팅 내용 리스트
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                itemCount: dialog.length,
                                itemBuilder: (context, index) {
                                  final item = dialog[index];
                                  if (item is! Map)
                                    return const SizedBox();

                                  final talker =
                                      (item["talker"] ?? "")
                                          .toString();
                                  final message =
                                      (item["message"] ?? "")
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
                                      crossAxisAlignment: isStaff
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.symmetric(
                                                vertical: 6,
                                              ),
                                          padding:
                                              const EdgeInsets.all(
                                                12,
                                              ),
                                          constraints:
                                              const BoxConstraints(
                                                maxWidth: 320,
                                              ),
                                          decoration: BoxDecoration(
                                            color: isStaff
                                                ? AppColors.sublack
                                                : Colors.white,
                                            border: Border.all(
                                              color: AppColors
                                                  .adminBorderColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(
                                                  12,
                                                ),
                                          ),
                                          child: Text(
                                            message,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w400,

                                              color: isStaff
                                                  ? AppColors.suyellow
                                                  : AppColors
                                                        .textColor,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                          child: Text(
                                            timeLabel,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w400,
                                              color:
                                                  AppColors.textColor,
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
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Center(child: Text("에러: $e")),
                    ),
                  ),

                  //  입력창 (반드시 Column의 bottom!)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: InputDecoration(
                              hintText: "메시지 입력",
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColor,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.adminBorderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.adminBorderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.adminTitleColor,
                                  width: 1.2,
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                            ),
                            onSubmitted: (_) => _send(selectedUserId),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _send(selectedUserId),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              backgroundColor: AppColors.sublack,
                              foregroundColor: AppColors.suyellow,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                              ),
                            ),
                            child: const Text(
                              "전송",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
