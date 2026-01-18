import 'package:flutter/material.dart';
import 'package:seatup_app/view/admin/admin_chat_list.dart';
import 'package:seatup_app/view/admin/admin_curtain_edit.dart';
import 'package:seatup_app/view/admin/admin_curtain_insert.dart';
import 'package:seatup_app/view/admin/admin_review_manage.dart';
import 'package:seatup_app/view/admin/admin_transaction_manage.dart';
import 'package:seatup_app/view/admin/admin_transaction_review_manage.dart';
import 'package:seatup_app/view/admin/faq_list.dart';

// ✅ 일단 다른 화면 import는 빼고, Placeholder로 처리(오류 방지)
// import 'package:seatup_app/view/admin/admin_chat_list.dart';
// import 'package:seatup_app/view/admin/admin_review_manage.dart';
// import 'package:seatup_app/view/admin/admin_transaction_manage.dart';
// import 'package:seatup_app/view/admin/admin_transaction_review_manage.dart';
// import 'package:seatup_app/view/admin/faq_list.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedMenuIndex = 0;

  final List<Map<String, dynamic>> rows = List.generate(30, (i) {
    return {
      'type': '뮤지컬',
      'title': '안나카레니나',
      'location': '서울',
      'place': '예술의 전당',
      'grade': 'vip',
      'area': 'F구역',
      'show_date': '2.11 ~ 3.20',
      'show_time': '14:00',
      'show_cast': '정선아 ...',
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Row(
          children: [
            _sideBar(),
            Expanded(
              child: IndexedStack(
                index: selectedMenuIndex,
                children: [
                  _productInfoTab(context),          // 0 제품 정보
                  FaqList(),           // 1
                  AdminTransactionManage(),    // 2
                  AdminReviewManage(),    // 3
                  AdminTransactionReviewManage(),    // 4
                  AdminChatList(),  // 5
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
  Widget _productInfoTab(BuildContext context) {
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
          _topPanel(),
          const SizedBox(height: 14),

          Expanded(
            child: Container(
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
                          headingRowHeight: 42,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 56,
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
                            DataColumn(label: Text('location')),
                            DataColumn(label: Text('place')),
                            DataColumn(label: Text('grade')),
                            DataColumn(label: Text('area')),
                            DataColumn(label: Text('show_date')),
                            DataColumn(label: Text('show_time')),
                            DataColumn(label: Text('show_cast')),
                            DataColumn(label: SizedBox(width: 56)),
                          ],
                          rows: List.generate(rows.length, (i) {
                            final r = rows[i];
                            return DataRow(
                              cells: [
                                DataCell(Text('${r['type']}')),
                                DataCell(Text('${r['title']}')),
                                DataCell(Text('${r['location']}')),
                                DataCell(Text('${r['place']}')),
                                DataCell(Text('${r['grade']}')),
                                DataCell(Text('${r['area']}')),
                                DataCell(Text('${r['show_date']}')),
                                DataCell(Text('${r['show_time']}')),
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      '${r['show_cast']}',
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
                                        // 수정부분
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
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Sidebar ----------------
  Widget _sideBar() {
    return Container(
      width: 170,
      color: const Color(0xFF4D74D6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          _sideItem('제품 정보', index: 0),
          _sideItem('게시판', index: 1),
          _sideItem('거래 글 리스트', index: 2),
          _sideItem('관람 후기 관리', index: 3),
          _sideItem('거래 후기 관리', index: 4),
          _sideItem('고객 채팅 리스트', index: 5),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                // 여기에 로그아웃
              },
              child: _sideLogout()
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideItem(String title, {required int index}) {
    final bool selected = selectedMenuIndex == index;

    return InkWell(
      onTap: () => setState(() => selectedMenuIndex = index),
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
  Widget _topPanel() {
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
              Icon(Icons.confirmation_number_outlined,
                  size: 22, color: Color(0xFF2F57C9)),
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
                      borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminCurtainInsert(),));
                },
                child: const Text('등록',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
