import 'package:flutter/material.dart';

class PurchaseHistoryDetail extends StatelessWidget {
  const PurchaseHistoryDetail({super.key});

  @override
  Widget build(BuildContext context) {
    // ====== 샘플 데이터(나중에 API 데이터로 교체) ======
    final order = OrderDetail(
      statusLeft: "PIN전달완료",
      statusRight: "거래완료",
      orderNo: "CM2025032614035435485",
      productNo: "3611439561040",
      categoryLine: "스포츠  >  야구 - 대전 이글스파크",
      title: "vs 한화  2:0  LG 승",
      seatInfo: "3루 2층(9.5m)   1열  10열",
      qtyLabel: "3장   e티켓(실물X)   |   특수조건없음",
      price: 80000,

      tradeTitle: "PIN전달(e-ticket) 거래",
      sellerNick: "수영",
      deliveryType: "티켓보유 여부",
      deliveryValue: "보유중",

      payMethod: "신용카드(GALAXIA) / 기타카드",
      paidAt: "2025.03.26 14:03",

      amountProduct: 80000,
      amountCoupon: 0,
      amountShipping: 0,
    );

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
            onPressed: () {},
            icon: const Icon(Icons.home_outlined, color: Colors.black),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        child: const Icon(Icons.chat_bubble_outline),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          _StatusStrip(
            left: order.statusLeft,
            right: order.statusRight,
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "주문 상품 정보",
            child: Column(
              children: [
                _KeyValueRow(label: "주문번호", value: order.orderNo),
                const SizedBox(height: 10),
                _OrderProductBlock(order: order),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "거래 정보",
            child: Column(
              children: [
                _KeyValueRow(label: "거래 형태", value: order.tradeTitle),
                const SizedBox(height: 10),
                _KeyValueRow(label: "판매자", value: order.sellerNick),
                const SizedBox(height: 10),
                _KeyValueRow(label: order.deliveryType, value: order.deliveryValue),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "결제 수단",
            child: Column(
              children: [
                _KeyValueRow(label: "결제 수단", value: order.payMethod),
                const SizedBox(height: 10),
                _KeyValueRow(label: "결제 일자", value: order.paidAt),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _SectionCard(
            title: "결제 금액",
            child: Column(
              children: [
                _MoneyRow(label: "상품 금액", amount: order.amountProduct),
                const SizedBox(height: 10),
                _MoneyRow(label: "쿠폰 할인", amount: -order.amountCoupon),
                const SizedBox(height: 10),
                _MoneyRow(label: "배송비", amount: order.amountShipping),
                const Divider(height: 22),
                _TotalMoneyRow(
                  label: "총 결제 금액",
                  amount: order.totalAmount,
                ),
              ],
            ),
          ),
        ],
      ),
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

class _OrderProductBlock extends StatelessWidget {
  final OrderDetail order;

  const _OrderProductBlock({required this.order});

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
            "상품번호  ${order.productNo}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.categoryLine,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            order.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.seatInfo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.qtyLabel,
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
              "${_formatMoney(order.price)}원",
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

// ======================= MODEL =======================

class OrderDetail {
  final String statusLeft;
  final String statusRight;

  final String orderNo;
  final String productNo;
  final String categoryLine;
  final String title;
  final String seatInfo;
  final String qtyLabel;
  final int price;

  final String tradeTitle;
  final String sellerNick;
  final String deliveryType;
  final String deliveryValue;

  final String payMethod;
  final String paidAt;

  final int amountProduct;
  final int amountCoupon;
  final int amountShipping;

  OrderDetail({
    required this.statusLeft,
    required this.statusRight,
    required this.orderNo,
    required this.productNo,
    required this.categoryLine,
    required this.title,
    required this.seatInfo,
    required this.qtyLabel,
    required this.price,
    required this.tradeTitle,
    required this.sellerNick,
    required this.deliveryType,
    required this.deliveryValue,
    required this.payMethod,
    required this.paidAt,
    required this.amountProduct,
    required this.amountCoupon,
    required this.amountShipping,
  });

  int get totalAmount => amountProduct - amountCoupon + amountShipping;
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
