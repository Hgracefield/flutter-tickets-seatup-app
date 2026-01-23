import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/util/btn_style.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_curtain_edit.dart';
import 'package:seatup_app/view/admin/admin_curtain_insert.dart';
import 'package:seatup_app/view/admin/admin_side_bar.dart';
import 'package:seatup_app/vm/admin_curtain_notifier.dart';

const double _colTypeWidth = 40;
const double _colTitleWidth = 200;
const double _colPlaceWidth = 180;
const double _colDateWidth = 90;
const double _colTimeWidth = 80;
const double _colDescWidth = 200;
const double _colActionWidth = 40;

const _curtainColumns = [
  DataColumn(
    label: SizedBox(width: _colTypeWidth, child: Text('type')),
  ),
  DataColumn(
    label: SizedBox(width: _colTitleWidth, child: Text('title')),
  ),
  DataColumn(
    label: SizedBox(width: _colPlaceWidth, child: Text('place')),
  ),
  DataColumn(
    label: SizedBox(width: _colDateWidth, child: Text('curtain_date')),
  ),
  DataColumn(
    label: SizedBox(width: _colTimeWidth, child: Text('curtain_time')),
  ),
  DataColumn(
    label: SizedBox(width: _colDescWidth, child: Text('curtain_desc')),
  ),
  DataColumn(label: SizedBox(width: _colActionWidth)),
];

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final dashboardAsync = ref.watch(staffNotifierProvider);
    return Scaffold(
      backgroundColor: AppColors.adminBackgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            AdminSideBar(selectedMenu: SideMenu.dashboard, onMenuSelected: (menu) {}),
            // _sideBar(context, ref, dashboardAsync),
            Expanded(
               child: _productInfoTab(context, ref)
            ),
          ],
        ),
      ),
    );
  }

  // 선택된 index만 build (안 보이는 탭은 아예 build 안 함)
  // Widget _buildBodyByIndex(BuildContext context, int selectedMenuIndex, WidgetRef ref) {
  //   switch (selectedMenuIndex) {
  //     case 0:
  //       return _productInfoTab(context, ref);
  //     case 1:
  //       return FaqList();
  //     case 2:
  //       return AdminTransactionManage();
  //     case 3:
  //       return AdminReviewManage();
  //     case 4:
  //       return AdminTransactionReviewManage();
  //     case 5:
  //       return AdminChatList();
  //     default:
  //       return _placeholderTab('알 수 없는 메뉴');
  //   }
  // }

  // ---------------- 탭 화면(임시) ----------------
  // Widget _placeholderTab(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(10),
  //         border: Border.all(color: const Color(0xFFCFD8FF)),
  //       ),
  //       child: Center(
  //         child: Text(
  //           '$title (준비중)',
  //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ---------------- 탭0: 제품 정보 ----------------
  Widget _productInfoTab(BuildContext context, WidgetRef ref) {
    final curtainAsync = ref.watch(adminCurtainNotifer);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '제품 정보',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textColor,
              // color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 14),
          _topPanel(context),
          const SizedBox(height: 14),

          Expanded(
            child: curtainAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('에러: $e')),
              data: (curtainList) => _curtainTable(context, curtainList),
            ),
          ),
        ],
      ),
    );
  }

  // 공통 위젯
  Widget _curtainTable(BuildContext context, List curtainList) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.adminBorderColor),
      ),
      child: Column(
        children: [
          _curtainTableHeader(),
          const Divider(height: 1),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: _curtainTableBody(context, curtainList),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 고정 헤더
  Widget _curtainTableHeader() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 980),
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 0,
        dataRowMaxHeight: 0,
        columnSpacing: 18,
        headingTextStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF2F57C9),
          fontWeight: FontWeight.w800,
        ),
        columns: _curtainColumns,
        rows: const [],
      ),
    );
  }

  Widget _curtainTableBody(BuildContext context, List curtainList) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 980),
      child: DataTable(
        headingRowHeight: 0, // 👈 헤더 숨김
        dataRowMinHeight: 36,
        dataRowMaxHeight: 40,
        columnSpacing: 18,
        dataTextStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w600,
        ),
        columns: _curtainColumns,
        rows: List.generate(curtainList.length, (i) {
          final r = curtainList[i];
          DataCell(
            SizedBox(
              width: _colTitleWidth,
              child: Text(
                r['title_contents'].toString(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );

          return DataRow(
            cells: [
              DataCell(Text(r['type_name'].toString())),
              DataCell(
                Text(
                  r['title_contents'].toString().length > 15
                      ? '${r['title_contents'].toString().substring(0, 15)}...'
                      : r['title_contents'].toString(),
                ),
              ),
              DataCell(Text(r['place_name'].toString())),
              DataCell(Text(r['curtain_date'].toString())),
              DataCell(Text(r['curtain_time'].toString())),
              DataCell(
                SizedBox(
                  width: 160,
                  child: Text(
                    r['curtain_desc'].toString().length > 10
                        ? '${r['curtain_desc'].toString().substring(0, 15)}...'
                        : r['curtain_desc'].toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 56,
                  height: 28,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.sublack,
                      foregroundColor: AppColors.suyellow,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      final initialData = Curtain(
                        curtain_id: r['curtain_id'],
                        curtain_date: (r['curtain_date'] ?? '').toString(),
                        curtain_time: (r['curtain_time'] ?? '').toString(),
                        curtain_desc: (r['curtain_desc'] ?? '').toString(),
                        curtain_mov: (r['curtain_mov'] ?? '').toString(),
                        curtain_pic: (r['curtain_pic'] ?? '').toString(),
                        curtain_place: (r['place_name'] ?? '').toString(),
                        curtain_type: (r['type_name'] ?? '').toString(),
                        curtain_title: (r['title_contents'] ?? '').toString(),
                        curtain_grade: int.tryParse('${r['curtain_grade']}') ?? 0,
                        curtain_area: int.tryParse('${r['curtain_area']}') ?? 0,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminCurtainEdit(initialData: initialData),
                        ),
                      );
                    },
                    child: const Text(
                      '수정',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ---------------- Sidebar ----------------
  // Widget _sideBar(
  //   BuildContext context,
  //   WidgetRef ref,
  //   AsyncValue<DashBoardState> dashboardAsync,
  // ) {
  //   final selectedIndex = dashboardAsync.value?.selectedMenuIndex ?? 0;

  //   return Container(
  //     width: 170,
  //     color: const Color(0xFF4D74D6),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const SizedBox(height: 18),
  //         _sideItem(ref, '제품 정보', index: 0, selectedIndex: selectedIndex),
  //         _sideItem(ref, '게시판', index: 1, selectedIndex: selectedIndex),
  //         _sideItem(ref, '거래 글 리스트', index: 2, selectedIndex: selectedIndex),
  //         _sideItem(ref, '관람 후기 관리', index: 3, selectedIndex: selectedIndex),
  //         _sideItem(ref, '거래 후기 관리', index: 4, selectedIndex: selectedIndex),
  //         _sideItem(ref, '고객 채팅 리스트', index: 5, selectedIndex: selectedIndex),
  //         const Spacer(),
  //         Padding(
  //           padding: const EdgeInsets.all(12.0),
  //           child: GestureDetector(
  //             onTap: () {
  //               ref.read(staffNotifierProvider.notifier).logout();
  //               Navigator.pop(context);
  //             },
  //             child: _sideLogout(),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _sideItem(
  //   WidgetRef ref,
  //   String title, {
  //   required int index,
  //   required int selectedIndex,
  // }) {
  //   final bool selected = selectedIndex == index;
  //   return InkWell(
  //     onTap: () {
  //       ref.read(staffNotifierProvider.notifier).setMenuIndex(index);
  //     },
  //     child: Container(
  //       width: double.infinity,
  //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  //       decoration: BoxDecoration(
  //         color: selected ? const Color(0xFF2F57C9) : Colors.transparent,
  //       ),
  //       child: Text(
  //         title,
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: 13,
  //           fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _sideLogout() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF2F57C9),
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: const Text(
  //       '로그아웃',
  //       style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
  //     ),
  //   );
  // }

  // ---------------- Top Panel ----------------
  Widget _topPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCFD8FF)),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(
                Icons.confirmation_number_outlined,
                size: 22,
                color: Color(0xFF2F57C9),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '티켓 리셀 상품을 등록·수정하고 공연/좌석 정보를 관리하세요.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Spacer(),
              BtnStyle.primary(
                text: '등록',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminCurtainInsert()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  } // build
} // class
