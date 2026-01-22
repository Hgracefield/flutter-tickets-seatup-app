import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/user/main_page.dart';
import 'package:seatup_app/view/user/purchase_history_detail.dart';
import 'package:seatup_app/vm/order_notifier.dart';
import 'package:seatup_app/vm/purchase_notifier.dart';
import 'package:seatup_app/vm/storage_provider.dart';

class PurchaseHistory extends ConsumerWidget {
  const PurchaseHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg = const Color(0xFFF6F7F9);

    // ✅ 지금은 샘플 데이터 그대로 사용
    // final List<PurchaseItem> items = [
    //   PurchaseItem(
    //     orderNo: "MI202308102318593CAF",
    //     orderDate: "2023.08.10",
    //     category: "스포츠",
    //     subCategory: "야구 - 대전 이글스파크",
    //     title: "금요일 113구역 M열",
    //     tag: "PIN",
    //     unitPrice: 25000,
    //     qty: 2,
    //     status: PurchaseStatus.done,
    //   ),
    //   PurchaseItem(
    //     orderNo: "MI20230810124915166E",
    //     orderDate: "2023.08.10",
    //     category: "스포츠",
    //     subCategory: "야구 - 고척돔 야구장",
    //     title: "110구역 H열",
    //     tag: "PIN",
    //     unitPrice: 16000,
    //     qty: 2,
    //     status: PurchaseStatus.done,
    //   ),
    // ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        centerTitle: true,
        title: const Text(
          "구매 이력 관리",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainPage()),
              );
            },
            icon: const Icon(Icons.home_outlined, color: Colors.black),
          ),
        ],
      ),

      // 탭/날짜 영역 제거하고 리스트만
      body: _HistoryList(),
    );
  }
}

class _HistoryList extends ConsumerWidget {

  const _HistoryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStorage = ref.watch(storageProvider).read('user_id');
    final purchaseAsync = ref.watch(purchaseDetailProvider(userStorage));
   return purchaseAsync.when(
      data: (data) {
       return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          itemCount: data.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseHistoryDetail(purchase: data[index],),)),
              child: _PurchaseCard(item: data[index])
            );
          },
        );
      },
      error: (error, stackTrace) => Text('error : $error'),
      loading: () => Center(child: Text('구매이력이 없습니다.')),
    );
  }
}

class _PurchaseCard extends ConsumerWidget {
  final Map<String,dynamic> item;

  const _PurchaseCard({required this.item});

  @override
  Widget build(BuildContext context , WidgetRef ref) {
    final totalPrice = item['post_quantity'] * item['post_price'];
    final orderNo = ref.read(orderProviderAsync.notifier)
                                .makeOrderNo(postSeq: item['post_seq'], postCreateDate: item['post_create_date']);

    final priceText = "${_formatMoney(totalPrice)}원";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EBEF)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 주문번호/주문일
            Row(
              children: [
                Expanded(
                  child: Text(
                    "주문번호 $orderNo",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "주문일 ${item['post_create_date']}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 카테고리 라인
            Text(
              "${item['type_name']}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // 타이틀 + 가격
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item['title_contents'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // PIN 뱃지 + 수량
            Row(
              children: [
                // _TagChip(text: item.tag),
                const SizedBox(width: 8),
                Text(
                  "${_formatMoney(item['post_price'])}원 × ${item['post_quantity']}장",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 하단 상태/버튼
            Row(
              children: [
                Text(
                  "거래완료",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                // const Spacer(),
                // if (item.status == PurchaseStatus.done)
                //   _OutlineMiniButton(text: "재판매", onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  const _TagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3E5EA)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _OutlineMiniButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _OutlineMiniButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD9DDE5)),
          color: Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

String _formatMoney(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
  }
  return buf.toString();
}

enum PurchaseStatus { progress, done, cancel }

extension PurchaseStatusUI on PurchaseStatus {
  String get label {
    switch (this) {
      case PurchaseStatus.progress:
        return "거래 진행";
      case PurchaseStatus.done:
        return "거래완료";
      case PurchaseStatus.cancel:
        return "거래 취소";
    }
  }

  Color get color {
    switch (this) {
      case PurchaseStatus.progress:
        return Colors.blueGrey;
      case PurchaseStatus.done:
        return Colors.black87;
      case PurchaseStatus.cancel:
        return Colors.redAccent;
    }
  }
}
