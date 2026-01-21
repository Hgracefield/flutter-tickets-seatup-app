import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_side_bar.dart';

// ========================================== 더미 데이터 모델 ==========================================

class AdminPost {
  final int id;
  final DateTime createdAt;
  final String category;
  final String title;
  final String author;

  AdminPost({
    required this.id,
    required this.createdAt,
    required this.category,
    required this.title,
    required this.author,
  });
}

/// 더미 데이터
final dummyAdminPosts = <AdminPost>[
  AdminPost(
    id: 1,
    createdAt: DateTime(2026, 1, 12),
    category: '뮤지컬',
    title: '레드북 뮤지컬 단장팝니다',
    author: '작성자',
  ),
  AdminPost(
    id: 2,
    createdAt: DateTime(2026, 1, 12),
    category: '뮤지컬',
    title: '레드북 뮤지컬 단장팝니다',
    author: '작성자',
  ),
];

// ============================================ 관리자 거래 글 관리 페이지 ==========================================

class AdminTransactionManage extends StatelessWidget {
  const AdminTransactionManage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            AdminSideBar(selectedMenu: SideMenu.transaction, onMenuSelected: (menu) {}),
            Expanded(
              child: Column(
                children: [
                  contentsTitle(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _tableHeader(),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.separated(
                              itemCount: dummyAdminPosts.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return _tableRow(dummyAdminPosts[index]);
                              },
                            ),
                          ),
                        ],
                      ),
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

  /// ============================================ 제목 ============================================

  Widget contentsTitle() {
    return Row(
      children: [
        Text(
          '거래 글 리스트',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }

  /// ============================================테이블 헤더============================================

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 16,
      ),
      child: Row(
        children: const [
          _HeaderCell('등록일', flex: 2),
          _HeaderCell('공연 타입', flex: 2),
          _HeaderCell('글 제목', flex: 5),
          _HeaderCell('작성자', flex: 2),
          SizedBox(width: 60),
        ],
      ),
    );
  }

  // ============================================ 테이블 Row ============================================

  Widget _tableRow(AdminPost post) {
    final date = DateFormat('yyyy.MM.dd').format(post.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 16,
      ),
      child: Row(
        children: [
          _BodyCell(date, flex: 2),
          _BodyCell(post.category, flex: 2),
          _BodyCell(post.title, flex: 5, align: TextAlign.left),
          _BodyCell(post.author, flex: 2),
          SizedBox(
            width: 80,
            child: OutlinedButton(
              onPressed: () {
                // TODO: MySQL delete API
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(4),
                ),
                side: BorderSide(color: AppColors.warnColor),
                backgroundColor: AppColors.warnColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================테이블 Cell 위젯==========================================

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;

  const _BodyCell(
    this.text, {
    required this.flex,
    this.align = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
