import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/util/side_menu.dart';
import 'package:seatup_app/view/admin/admin_side_bar.dart';
import 'package:seatup_app/vm/post_notifier.dart';

// ============================================ 관리자 거래 글 관리 페이지 ==========================================

class AdminTransactionManage extends ConsumerWidget {
  const AdminTransactionManage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      // body: SafeArea(
      //   child: Row(
      //     children: [
      //       AdminSideBar(selectedMenu: SideMenu.transaction, onMenuSelected: (menu) {}),
      //       Expanded(
      //         child: Column(
      //           children: [
      //             contentsTitle(),
      //             const SizedBox(height: 12),
      //             Expanded(
      //               child: Container(
      //                 decoration: BoxDecoration(
      //                   border: Border.all(color: Colors.black),
      //                   borderRadius: BorderRadius.circular(12),
      //                 ),
      //                 child: Column(
      //                   children: [
      //                     _tableHeader(),
      //                     const Divider(height: 1),
      //                     Expanded(
      //                       child: postAsync.when(
      //                         loading: () =>
      //                             const Center(child: CircularProgressIndicator()),
      //                         error: (e, stackTrace) => Center(child: Text('에러 발생 : $e')),
      //                         data: (posts) => ListView.separated(
      //                           itemCount: posts.length,
      //                           separatorBuilder: (_, __) => const Divider(height: 1),
      //                           itemBuilder: (context, index) {
      //                             return _tableRow(posts[index]);
      //                           },
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  /// ============================================ 제목 ============================================

  //   Widget contentsTitle() {
  //     return Row(
  //       children: [
  //         Text(
  //           '거래 글 리스트',
  //           style: TextStyle(
  //             fontSize: 22,
  //             fontWeight: FontWeight.bold,
  //             color: AppColors.textColor,
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  //   /// ============================================테이블 헤더============================================

  //   Widget _tableHeader() {
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  //       child: Row(
  //         children: const [
  //           _HeaderCell('등록일', flex: 2),
  //           _HeaderCell('공연 타입', flex: 2),
  //           _HeaderCell('공연 이름', flex: 2),
  //           _HeaderCell('공연 상세...', flex: 2),
  //           _HeaderCell('작성자', flex: 2),
  //           SizedBox(width: 60),
  //         ],
  //       ),
  //     );
  //   }

  //   // ============================================ 테이블 Row ============================================

  //   Widget _tableRow(Post post) {
  //     final date = DateFormat('yyyy.MM.dd').format(post.createdAt);

  //     return Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  //       child: Row(
  //         children: [
  //           _BodyCell(date, flex: 2),
  //           _BodyCell(post.categoryName, flex: 2),
  //           _BodyCell(post.title, flex: 2),
  //           _BodyCell(post.detail ?? '-', flex: 2, align: TextAlign.left),
  //           _BodyCell(post.writerName, flex: 2),
  //           SizedBox(
  //             width: 80,
  //             child: OutlinedButton(
  //               onPressed: () {
  //                 // TODO: MySQL delete API
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadiusGeometry.circular(4),
  //                 ),
  //                 side: BorderSide(color: AppColors.warnColor),
  //                 backgroundColor: AppColors.warnColor,
  //                 foregroundColor: Colors.white,
  //               ),
  //               child: const Text('삭제', style: TextStyle(fontSize: 13)),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // // ============================================테이블 Cell 위젯==========================================

  // class _HeaderCell extends StatelessWidget {
  //   final String text;
  //   final int flex;

  //   const _HeaderCell(this.text, {required this.flex});

  //   @override
  //   Widget build(BuildContext context) {
  //     return Expanded(
  //       flex: flex,
  //       child: Text(
  //         text,
  //         textAlign: TextAlign.center,
  //         style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
  //       ),
  //     );
  //   }
  // }

  // class _BodyCell extends StatelessWidget {
  //   final String text;
  //   final int flex;
  //   final TextAlign align;
  //   const _BodyCell(this.text, {required this.flex, this.align = TextAlign.center});

  //   @override
  //   Widget build(BuildContext context) {
  //     return Expanded(
  //       flex: flex,
  //       child: Text(
  //         text,
  //         textAlign: align,
  //         overflow: TextOverflow.ellipsis,
  //         style: const TextStyle(fontSize: 14),
  //       ),
  //     );
  //   }
}
