import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/post.dart';
import 'package:seatup_app/util/message.dart';
import 'package:seatup_app/view/user/main_page.dart';
import 'package:seatup_app/view/user/map_view.dart';
import 'package:seatup_app/view/user/payment.dart';
import 'package:seatup_app/view/user/user_to_user_chat.dart';
import 'package:seatup_app/vm/agree_check.dart';
import 'package:seatup_app/vm/post_notifier.dart';
import 'package:seatup_app/vm/route_vm.dart';
import 'package:seatup_app/vm/storage_provider.dart';
import 'package:seatup_app/vm/user_chat_notifier.dart';

class TicketDetail extends ConsumerWidget {
  final int postSeq;
  const TicketDetail({super.key, required this.postSeq});

  // // ====== 더미 데이터(네 프로젝트 모델로 바꿔 끼우면 됨) ======
  // final String productTitle = "티켓상세페이지";
  // final String productNo = "6253999853264";

  // final String routeText = "뮤지컬  >  title여기다가";
  // final String showDateTime = "2026.03.06 20:00";

  // final String seatTitle = "VVIP등급  | A구역";
  // final String seatSub = "여기에는 post 설명";

  // final int price = 440000;
  // final int qty = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postSelectAllProvider(postSeq));
    final agreeCheck = ref.watch(agreeNotifier);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        actions: [
         IconButton(
            onPressed: () {
              final post = postAsync.asData?.value;
              if (post == null) return;

              final placeSeq = post['place_seq'];
              if (placeSeq == null) return;

              ref.read(selectedPlaceSeqProvider.notifier).state =
                  placeSeq;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapView()),
              );
            },
            icon: const Icon(Icons.map),
          ),
        ],
      ),

      // ✅ float 버튼 없음 (Stack/Positioned 미사용)
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        child: postAsync.when(
          data: (post) {
            final total = post['post_quantity'] * post['post_price'];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _productInfoCard(post, ref),
                const SizedBox(height: 12),

                _priceCard(post, ref, total: total),
                const SizedBox(height: 12),

                _mustCheckCard(
                  agreeNotice: agreeCheck.agreeNotice,
                  agreeRefund: agreeCheck.agreeRefund,
                  onTapDetail: () => _showMustCheckSheet(context),
                  onChangeNotice: (value) =>
                      ref.read(agreeNotifier.notifier).agreeChangeNotice(value),
                  onChangeRefund: (value) =>
                      ref.read(agreeNotifier.notifier).agreeChangeRefund(value),
                ),
              ],
            );
          },
          error: (error, stackTrace) => Text('에러: $error'),
          loading: () => Center(child: CircularProgressIndicator()),
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, -6),
                color: Color(0x14000000),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    Message message = Message();
                    final post = await ref
                        .read(postNotifierProvider.notifier)
                        .selectPostAll(postSeq);
                    if(!context.mounted) return;
                    if (post['post_user_id'].toString() ==
                        ref.watch(storageProvider).read('user_id').toString()) {
                      message.errorSnackBar(context, 'Error');
                    } else {
                      final roomSnap = await ref
                          .read(chatNotifierProvider.notifier)
                          .openChat(
                            post['post_seq'].toString(),
                            post['post_user_id'].toString(),
                          );
                      if(!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return UserToUserChat(
                              postId: post['post_seq'].toString(),
                              partnerId: roomSnap,
                            );
                          },
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: Color(0xFFE6E8EE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '1:1채팅',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: (agreeCheck.agreeNotice && agreeCheck.agreeRefund)
                      ? () async {
                          final post = await ref.read(
                            postDetailProvider(postSeq).future,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                post: post,
                                buyerId: ref
                                    .watch(storageProvider)
                                    .read('user_id'),
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '구매하기',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== UI Widgets =====================

  Widget _productInfoCard(Map<String, dynamic> postAsync, WidgetRef ref) {
    final ticketNumber = ref
        .read(postNotifierProvider.notifier)
        .ticketNumber(
          postAsync['post_create_date'],
          postAsync['post_seq'],
          postAsync['curtain_id'],
        );
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: "상품 정보" + 상품번호
          Row(
            children: [
              const Expanded(
                child: Text(
                  '상품 정보',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
              Text(
                '상품번호 $ticketNumber',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 분류/경로
          Text(
            '${postAsync['type_name']} > ${postAsync['title_contents']}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),

          // 공연일시
          Row(
            children: [
              const Text(
                '공연일시  ',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${postAsync['curtain_date']} ${postAsync['curtain_time']}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // 좌석 정보
          Text(
            '${postAsync['grade_name']}등급',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            '${postAsync['area_number']}구역',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            '${postAsync['post_desc']}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard(
    Map<String, dynamic> postAsync,
    WidgetRef ref, {
    required int total,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '결제 정보',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 12),

          _kv('한 매 가격', _won(postAsync['post_price'])),
          const SizedBox(height: 10),
          _kv('수량', '${postAsync['post_quantity']}매'),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Row(
            children: [
              const Expanded(
                child: Text(
                  '총 가격',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                _won(total),
                style: const TextStyle(
                  color: Color(0xFFFF2D55),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _mustCheckCard({
    required bool agreeNotice,
    required bool agreeRefund,
    required VoidCallback onTapDetail,
    required ValueChanged<bool> onChangeNotice,
    required ValueChanged<bool> onChangeRefund,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '구매 전 꼭 확인',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
              TextButton(onPressed: onTapDetail, child: const Text('자세히')),
            ],
          ),
          const SizedBox(height: 6),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: agreeNotice,
            onChanged: (v) => onChangeNotice(v ?? false),
            title: const Text(
              '안내 사항을 확인했어요',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: agreeRefund,
            onChanged: (v) => onChangeRefund(v ?? false),
            title: const Text(
              '취소/환불 규정을 확인했어요',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  // ===================== Helpers =====================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECF2)),
      ),
      child: child,
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }

  String _won(int value) {
    // 간단 천단위
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buf.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buf.write(',');
    }
    return '${buf.toString()}원';
  }

  void _showMustCheckSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '구매 전 꼭 확인',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              _bullet('예매 후 취소/환불은 규정에 따라 수수료가 발생할 수 있어요.'),
              _bullet('입장/구역/좌석 정보는 구매 후 변경이 제한될 수 있어요.'),
              _bullet('현장 상황에 따라 운영 방식이 변동될 수 있어요.'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '확인했어요',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
