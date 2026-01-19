import 'package:flutter/material.dart';

class PurchaseHistory extends StatefulWidget {
  const PurchaseHistory({super.key});

  @override
  State<PurchaseHistory> createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<PurchaseItem> _items = [
    PurchaseItem(
      orderNo: "MI202308102318593CAF",
      orderDate: "2023.08.10",
      category: "스포츠",
      subCategory: "야구 - 대전 이글스파크",
      title: "금요일 113구역 M열",
      tag: "PIN",
      unitPrice: 25000,
      qty: 2,
      status: PurchaseStatus.done,
    ),
    PurchaseItem(
      orderNo: "MI20230810124915166E",
      orderDate: "2023.08.10",
      category: "스포츠",
      subCategory: "야구 - 고척돔 야구장",
      title: "110구역 H열",
      tag: "PIN",
      unitPrice: 16000,
      qty: 2,
      status: PurchaseStatus.done,
    ),
    PurchaseItem(
      orderNo: "MI20230727234105731F",
      orderDate: "2023.07.27",
      category: "스포츠",
      subCategory: "야구 - 인천SSG랜더스필드 [SSG]",
      title: "토요일@29구역 H열",
      tag: "PIN",
      unitPrice: 28500,
      qty: 2,
      status: PurchaseStatus.progress,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PurchaseItem> _filteredItems(PurchaseStatus status) {
    return _items.where((e) => e.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF6F7F9);

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
            onPressed: () {},
            icon: const Icon(Icons.home_outlined, color: Colors.black),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 2,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: "거래 진행"),
                Tab(text: "거래 완료"),
                Tab(text: "거래 취소"),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 기간/필터 영역
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "2023.02.01 ~ 2026.01.13",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.tune, size: 20, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 리스트
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _HistoryList(items: _filteredItems(PurchaseStatus.progress)),
                _HistoryList(items: _filteredItems(PurchaseStatus.done)),
                _HistoryList(items: _filteredItems(PurchaseStatus.cancel)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<PurchaseItem> items;

  const _HistoryList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          "내역이 없습니다",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _PurchaseCard(item: items[index]);
      },
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final PurchaseItem item;

  const _PurchaseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final priceText = "${_formatMoney(item.totalPrice)}원";
    final statusLabel = item.status.label;
    final statusColor = item.status.color;

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
                    "주문번호 ${item.orderNo}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "주문일 ${item.orderDate}",
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
              "${item.category}  >  ${item.subCategory}",
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
                    item.title,
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

            // PIN 뱃지
            Row(
              children: [
                _TagChip(text: item.tag),
                const SizedBox(width: 8),
                Text(
                  "${_formatMoney(item.unitPrice)}원 × ${item.qty}장",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 하단 버튼/상태
            Row(
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                if (item.status == PurchaseStatus.done)
                  _OutlineMiniButton(
                    text: "재판매",
                    onTap: () {},
                  ),
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

class PurchaseItem {
  final String orderNo;
  final String orderDate;
  final String category;
  final String subCategory;
  final String title;
  final String tag;
  final int unitPrice;
  final int qty;
  final PurchaseStatus status;

  PurchaseItem({
    required this.orderNo,
    required this.orderDate,
    required this.category,
    required this.subCategory,
    required this.title,
    required this.tag,
    required this.unitPrice,
    required this.qty,
    required this.status,
  });

  int get totalPrice => unitPrice * qty;
}
