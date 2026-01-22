import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/user/main_page.dart';
import 'package:seatup_app/vm/order_notifier.dart';

class PurchaseHistoryDetail extends ConsumerWidget {
  final Map<String, dynamic> purchase;
  const PurchaseHistoryDetail({super.key, required this.purchase});

  @override
  Widget build(BuildContext context , WidgetRef ref) {
    final bg = const Color(0xFFF6F7F9);
    final totalPrice = purchase['post_quantity'] * purchase['post_price'];
    final orderNo = ref.read(orderProviderAsync.notifier)
                                .makeOrderNo(postSeq: purchase['post_seq'], postCreateDate: purchase['post_create_date']);
    final String product = ref.read(orderProviderAsync.notifier)
                        .ticketNumber(purchase['post_create_date'].toString(), purchase['post_seq'], purchase['purchase_post_id']);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.6,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "주문서 상세",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          // ✅ 상태 문구(핀전달완료) 제거한 안내 박스
          // _InfoBanner(
          //   text: "결제 완료 후 판매자가 PIN을 전달합니다.\n전달 완료 시 거래내역에서 확인할 수 있습니다.",
          // ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "주문 상품 정보",
            child: Column(
              children: [
                _KeyValueRow(label: "주문번호", value: orderNo),
                const SizedBox(height: 8),
                _KeyValueRow(label: "주문일시", value: purchase['purchase_date']),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _ProductBlock(
                    productNo: product,
                    categoryLine: purchase['type_name'],
                    title: purchase['title_contents'],
                    qty: purchase['post_quantity'],
                    unitPrice: purchase['post_price'],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "거래 정보",
            child: Column(
              children: const [
                // _KeyValueRow(label: "거래 방식", value: "tosspay 거래"),
                // SizedBox(height: 10),
                _KeyValueRow(label: "티켓 보유 여부", value: "보유중"),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "결제 수단",
            child: Column(
              children: [
                _KeyValueRow(label: "결제 수단", value: "tosspay"),
                SizedBox(height: 10),
                _KeyValueRow(label: "결제자", value: purchase['user_name']),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "결제 금액",
            child: Column(
              children: [
                _MoneyRow(label: "상품 금액", amount: purchase['post_price']),
                // const SizedBox(height: 10),
                // _MoneyRow(label: "쿠폰 할인", amount: 0),
                // const SizedBox(height: 10),
                // _MoneyRow(label: "배송비", amount: 0),
                const Divider(height: 22),
                _TotalMoneyRow(label: "총 결제 금액", amount: totalPrice),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ✅ 하단 플로팅 느낌 버튼 (선택)
          // _BottomActionButton(
          //   text: "문의하기",
          //   onTap: () {},
          // ),
        ],
      ),
    );
  }
}

// ---------------- UI ----------------

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
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

class _ProductBlock extends StatelessWidget {
  final String productNo;
  final String categoryLine;
  final String title;
  final int qty;
  final int unitPrice;

  const _ProductBlock({
    required this.productNo,
    required this.categoryLine,
    required this.title,
    required this.qty,
    required this.unitPrice,
  });

  @override
  Widget build(BuildContext context) {
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
            "상품번호  $productNo",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            categoryLine,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${_formatMoney(unitPrice)}원 × $qty장",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
              fontWeight: FontWeight.w700,
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
    final text = "${_formatMoney(amount)}원";
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

class _BottomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _BottomActionButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 14,
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
