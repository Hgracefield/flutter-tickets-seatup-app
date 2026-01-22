import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/post.dart';
import 'package:seatup_app/view/user/main_page.dart';
import 'package:seatup_app/vm/order_notifier.dart';
import 'package:seatup_app/vm/post_notifier.dart';

class PurchaseHistoryDetail extends ConsumerWidget {
  final Post post;
  const PurchaseHistoryDetail({super.key,required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderPostNotifier = ref.watch(postSelectAllProvider(post.post_seq!));
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "주문상세",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage(),));
            },
            icon: const Icon(Icons.home_outlined, color: Colors.black),
          ),
        ],
      ),
      body: orderPostNotifier.when(
        data: (data) {
          final total = data['post_quantity'] * data['post_price'];
          final orderNo = ref.read(orderProviderAsync.notifier)
                                .makeOrderNo(postSeq: data['post_seq'], postCreateDate: data['post_create_date']);
          return ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          _StatusStrip(
            left: "티켓주문완료",
            right: "거래완료",
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "주문 상품 정보",
            child: Column(
              children: [
                _KeyValueRow(label: "주문번호", value: orderNo),
                const SizedBox(height: 10),
                _OrderProductBlock(postData: data,),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "거래 정보",
            child: Column(
              children: [
                // _KeyValueRow(label: "거래 형태", value: order.tradeTitle),
                // const SizedBox(height: 10),
                _KeyValueRow(label: "판매자", value: data['user_name']),
                const SizedBox(height: 10),
                _KeyValueRow(label: "티켓보유 여부", value: "보유중"),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "결제 수단",
            child: Column(
              children: [
                _KeyValueRow(label: "결제 수단", value: "tosspay"),
                const SizedBox(height: 10),
                _KeyValueRow(label: "결제 일자", value: data['post_create_date']),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "결제 금액",
            child: Column(
              children: [
                _MoneyRow(label: "상품 금액", amount: data['post_price']),
                const SizedBox(height: 10),
                // _MoneyRow(label: "쿠폰 할인", amount: -order.amountCoupon),
                // const SizedBox(height: 10),
                // _MoneyRow(label: "배송비", amount: order.amountShipping),
                // const Divider(height: 22),
                _TotalMoneyRow(
                  label: "총 결제 금액",
                  amount: total,
                ),
              ],
            ),
          ),
        ],
      );
        }, 
        error: (error, stackTrace) => Text('에러 : $error'), 
        loading: () => Center(child: CircularProgressIndicator(),),
      )
      
    );
  }
}

// ======================= UI WIDGETS =======================

class _StatusStrip extends StatelessWidget {
  final String left;
  final String right;

  const _StatusStrip({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Row(
        children: [
          _Pill(text: left, bg: const Color(0xFFF2F3F5), fg: Colors.black87),
          const Spacer(),
          Text(
            right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _OrderProductBlock extends ConsumerWidget {
  final Map<String,dynamic> postData;

  const _OrderProductBlock({required this.postData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   final productNumber =
    ref.read(orderProviderAsync.notifier).ticketNumber(
      postData['post_create_date'],
      postData['post_seq'],
      postData['curtain_id'],
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "상품번호  $productNumber",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${postData['type_name']}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            postData['title_contents'],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${postData['grade_name']} | ${postData['area_number']}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${postData['post_quantity']}장",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${_formatMoney(postData['post_price'])}원",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final int amount;

  const _MoneyRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final isMinus = amount < 0;
    final text = "${isMinus ? '-' : ''}${_formatMoney(amount.abs())}원";

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TotalMoneyRow extends StatelessWidget {
  final String label;
  final int amount;

  const _TotalMoneyRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          "${_formatMoney(amount)}원",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3E5EA)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: fg,
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
