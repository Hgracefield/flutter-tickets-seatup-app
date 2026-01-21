import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_side_bar.dart';
import 'package:seatup_app/vm/admin_post_notifier.dart';
import 'package:http/http.dart' as http;

// ========================= 관리자 거래 글 관리 페이지 ==========================================

class AdminTransactionManage extends ConsumerWidget {
  const AdminTransactionManage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🔥 AdminTransactionManage BUILD');
    final postAsync = ref.watch(adminPostListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            AdminSideBar(selectedMenu: SideMenu.transaction, onMenuSelected: (_) {}),
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
                            child: postAsync.when(
                              loading: () =>
                                  const Center(child: CircularProgressIndicator()),
                              error: (e, _) => Center(child: Text('에러 발생: $e')),
                              data: (posts) => ListView.separated(
                                itemCount: posts.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final r = posts[index];
                                  debugPrint('ADMIN POST ROW => $r');

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        _BodyCell(
                                          r['post_create_date']?.toString() ?? '-',
                                          flex: 2,
                                        ),
                                        _BodyCell(r['type_name'] ?? '-', flex: 2),
                                        _BodyCell(r['title_contents'] ?? '-', flex: 2),

                                        _BodyCell('${r['post_price']}원', flex: 2),
                                        _BodyCell(r['user_name'] ?? '-', flex: 2),

                                        SizedBox(
                                          width: 80,
                                          child: OutlinedButton(
                                            onPressed: () async {
                                              await _updateStatus(ref, r['post_seq'], 1);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              backgroundColor: AppColors.warnColor,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text(
                                              '판매완료',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
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
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    child: Row(
      children: const [
        _HeaderCell('등록일', flex: 2),
        _HeaderCell('type', flex: 2),
        _HeaderCell('title', flex: 2),
        _HeaderCell('가격', flex: 2),
        _HeaderCell('작성자', flex: 2),
        SizedBox(width: 80),
      ],
    ),
  );
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
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}

Future<void> _updateStatus(WidgetRef ref, int postSeq, int status) async {
  await http.get(
    Uri.parse('http://172.16.250.217:8000/post/updateStatus?seq=$postSeq&status=$status'),
  );
  ref.invalidate(adminPostListProvider);
}

class _BodyCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;
  const _BodyCell(this.text, {required this.flex, this.align = TextAlign.center});

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
} // class
