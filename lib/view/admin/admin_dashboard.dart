import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/view/admin/admin_chat_list.dart';
import 'package:seatup_app/view/admin/admin_curtain_edit.dart';
import 'package:seatup_app/view/admin/admin_curtain_insert.dart';
import 'package:seatup_app/view/admin/admin_review_manage.dart';
import 'package:seatup_app/view/admin/admin_transaction_manage.dart';
import 'package:seatup_app/view/admin/admin_transaction_review_manage.dart';
import 'package:seatup_app/view/admin/faq_list.dart';
import 'package:seatup_app/vm/curtain_notifier.dart';
import 'package:seatup_app/vm/staff_notifier.dart';
import 'package:seatup_app/vm/storage_provider.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  // final List<Map<String, dynamic>> rows = List.generate(30, (i) {
  //   return {
  //     'type': '뮤지컬',
  //     'title': '안나카레니나',
  //     'location': '서울',
  //     'place': '예술의 전당',
  //     'grade': 'vip',
  //     'area': 'F구역',
  //     'show_date': '2.11 ~ 3.20',
  //     'show_time': '14:00',
  //     'show_cast': '정선아 ...',
  //   };
  // });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(staffNotifierProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Row(
          children: [
            _sideBar(context, ref, dashboardAsync),
            Expanded(
              child: dashboardAsync.when(
                data: (dash) =>
                    _buildBodyByIndex(context, dash.selectedMenuIndex, ref),
                error: (error, stackTrace) => Center(child: Text('에러: $error')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 선택된 index만 build (안 보이는 탭은 아예 build 안 함)
  Widget _buildBodyByIndex(
    BuildContext context,
    int selectedMenuIndex,
    WidgetRef ref,
  ) {
    switch (selectedMenuIndex) {
      case 0:
        return _productInfoTab(context, ref);
      case 1:
        return FaqList();
      case 2:
        return AdminTransactionManage();
      case 3:
        return AdminReviewManage();
      case 4:
        return AdminTransactionReviewManage();
      case 5:
        return AdminChatList();
      default:
        return _placeholderTab('알 수 없는 메뉴');
    }
  }

  // ---------------- 탭 화면(임시) ----------------
  Widget _placeholderTab(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCFD8FF)),
        ),
        child: Center(
          child: Text(
            '$title (준비중)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  // ---------------- 탭0: 제품 정보 ----------------
  Widget _productInfoTab(BuildContext context, WidgetRef ref) {
    final curtainAsync = ref.watch(curtainAllProvider);
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
              color: Color(0xFF1E3A8A),
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

  Widget _curtainTable(BuildContext context, List curtainList) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCFD8FF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 980),
                child: DataTable(
                  headingRowHeight: 36,
                  dataRowMinHeight: 36,
                  dataRowMaxHeight: 40,
                  columnSpacing: 18,
                  headingTextStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2F57C9),
                    fontWeight: FontWeight.w800,
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                  columns: const [
                    DataColumn(label: Text('type')),
                    DataColumn(label: Text('title')),
                    DataColumn(label: Text('place')),
                    DataColumn(label: Text('curtain_date')),
                    DataColumn(label: Text('curtain_time')),
                    DataColumn(label: Text('curtain_desc')),
                    DataColumn(label: SizedBox(width: 56)),
                  ],
                  rows: List.generate(curtainList.length, (i) {
                    final r = curtainList[i];

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
                                backgroundColor: const Color(0xFF4D74D6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                final initialData = Curtain(
                                  curtain_id: r['curtain_id'],
                                  curtain_date: (r['curtain_date'] ?? '')
                                      .toString(),
                                  curtain_time: (r['curtain_time'] ?? '')
                                      .toString(),
                                  curtain_desc: (r['curtain_desc'] ?? '')
                                      .toString(),
                                  curtain_mov: (r['curtain_mov'] ?? '')
                                      .toString(),
                                  curtain_pic: (r['curtain_pic'] ?? '')
                                      .toString(),
                                  curtain_place: (r['place_name'] ?? '')
                                      .toString(), // ✅
                                  curtain_type: (r['type_name'] ?? '')
                                      .toString(), // ✅
                                  curtain_title: (r['title_contents'] ?? '')
                                      .toString(), // ✅
                                  curtain_grade:
                                      int.tryParse('${r['curtain_grade']}') ??
                                      0,
                                  curtain_area:
                                      int.tryParse('${r['curtain_area']}') ?? 0,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminCurtainEdit(
                                      initialData: initialData,
                                    ),
                                  ),
                                );
                                debugPrint('pressed: ${r.keys}');
                              },

                              child: const Text(
                                '수정',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Sidebar ----------------
  Widget _sideBar(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DashBoardState> dashboardAsync,
  ) {
    final selectedIndex = dashboardAsync.value?.selectedMenuIndex ?? 0;

    return Container(
      width: 170,
      color: const Color(0xFF4D74D6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          _sideItem(ref, '제품 정보', index: 0, selectedIndex: selectedIndex),
          _sideItem(ref, '게시판', index: 1, selectedIndex: selectedIndex),
          _sideItem(ref, '거래 글 리스트', index: 2, selectedIndex: selectedIndex),
          _sideItem(ref, '관람 후기 관리', index: 3, selectedIndex: selectedIndex),
          _sideItem(ref, '거래 후기 관리', index: 4, selectedIndex: selectedIndex),
          _sideItem(ref, '고객 채팅 리스트', index: 5, selectedIndex: selectedIndex),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                ref.read(staffNotifierProvider.notifier).logout();
                Navigator.pop(context);
              },
              child: _sideLogout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideItem(
    WidgetRef ref,
    String title, {
    required int index,
    required int selectedIndex,
  }) {
    final bool selected = selectedIndex == index;
    return InkWell(
      onTap: () {
        ref.read(staffNotifierProvider.notifier).setMenuIndex(index);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2F57C9) : Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _sideLogout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2F57C9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '로그아웃',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D74D6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminCurtainInsert(),
                    ),
                  );
                },
                child: const Text(
                  '등록',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
