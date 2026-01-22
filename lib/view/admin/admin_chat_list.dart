import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_side_bar.dart';
import 'package:seatup_app/vm/chat_provider.dart';
import 'package:seatup_app/vm/storage_provider.dart';
import 'package:seatup_app/util/color.dart';

import 'admin_chat_detail.dart';

class AdminChatList extends ConsumerStatefulWidget {
  const AdminChatList({super.key});

  @override
  ConsumerState<AdminChatList> createState() => _AdminChatListState();
}

class _AdminChatListState extends ConsumerState<AdminChatList> {
  // 배정 버튼 스타일(검정 배경 + 노랑 글씨)
  ButtonStyle get _assignBtnStyle => OutlinedButton.styleFrom(
    minimumSize: const Size(0, 48),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    backgroundColor: AppColors.sublack,
    foregroundColor: AppColors.suyellow,
    side: const BorderSide(color: AppColors.sublack),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  // 채팅 열기 버튼(아이콘) 색상
  Color get _chatIconColor => AppColors.adminTitleColor;

  void _openDetail(String userId) {
    // 선택된 userId 저장
    ref.read(adminSelectedUserIdProvider.notifier).state = userId;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminChatDetail(userId: userId),
      ),
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
      SnackBar(
        backgroundColor: AppColors.sublack,
        content: Text(
          " $userId 고객을 $staffId 로 배정 완료",
          style: const TextStyle(
            color: AppColors.suyellow,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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

    return SafeArea(
      child: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.chatlist,
            onMenuSelected: (menu) {},
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor:
                    AppColors.adminBackgroundColor, //  배경 색
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  title: Text(
                    "관리자 채팅 (staff_seq: $staffId)",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.adminTitleColor,
                    ),
                  ),
                  bottom: const TabBar(
                    labelColor: AppColors.adminTitleColor,
                    unselectedLabelColor: AppColors.textColor,
                    indicatorColor: AppColors.adminTitleColor,
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
                          return const Center(
                            child: Text(
                              "미배정 채팅방이 없습니다.",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColor,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data();
                            final userId = doc.id;

                            final startAt = (data["startAt"] ?? "")
                                .toString();
                            final dialog =
                                (data["dialog"] as List?) ?? [];

                            String lastMsg = "";
                            if (dialog.isNotEmpty) {
                              final last = dialog.last;
                              if (last is Map) {
                                lastMsg = (last["message"] ?? "")
                                    .toString();
                              }
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // 카드 배경
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                                border: Border.all(
                                  color: AppColors.adminBorderColor,
                                ),
                              ),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                title: Text(
                                  "고객: $userId",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  "시작일: $startAt\n마지막내용: $lastMsg",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor,
                                  ),
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
                                      style:
                                          _assignBtnStyle, //  버튼 스타일 적용
                                      child: const Text("배정"),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () =>
                                          _openDetail(userId),
                                      icon: const Icon(Icons.chat),
                                      color:
                                          _chatIconColor, // 아이콘 색상 적용
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Center(child: Text("에러: $e")),
                    ),

                    // 2) 내 담당 채팅방 (입력 필요 X)
                    _MyRoomsList(
                      staffId: staffId,
                      onOpen: _openDetail,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            child: Text(
              "담당 중인 채팅방이 없습니다. (staffId: $staffId)",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
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

            return InkWell(
              onTap: () => onOpen(userId),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.adminBorderColor,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  title: Text(
                    "고객: $userId",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  subtitle: Text(
                    "시작일: $startAt\n마지막: $lastMsg",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColor,
                    ),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.adminTitleColor,
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("에러: $e")),
    );
  }
}
