import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/user/curtain_list_screen.dart';
import 'package:seatup_app/vm/category_provider.dart';

class Category extends ConsumerStatefulWidget {
  const Category({super.key});

  @override
  ConsumerState<Category> createState() => _CategoryState();
}

class _CategoryState extends ConsumerState<Category> {
  // DB type 테이블의 type_seq 매핑
  // 네 DB 기준: 연극=1, 뮤지컬=2, 콘서트=5, 무용=7, 전시=8
  int? _toTypeSeq(TicketCategory category) {
    switch (category) {
      case TicketCategory.play:
        return 1;
      case TicketCategory.musical:
        return 2;
      case TicketCategory.concert:
        return 5;
      case TicketCategory.classic:
        return 7;
      case TicketCategory.expo:
        return 8;

      // DB에 타입이 없거나 아직 준비중이면 null
      case TicketCategory.sports:
      case TicketCategory.leisure:
      case TicketCategory.kids:
      case TicketCategory.topping:
      case TicketCategory.benefit:
        return null;
    }
  }

  // 카테고리 선택 + typeSeq 저장 + 화면 이동/스낵바 처리
  void _selectCategoryAndMove({
    required TicketCategory category,
    required bool goListPage,
    String? snackMessage,
  }) {
    // 1) category + typeSeq 같이 저장
    ref
        .read(categoryFilterProvider.notifier)
        .select(category: category, typeSeq: _toTypeSeq(category));

    // 2) 이동 또는 안내문
    if (goListPage) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CurtainListScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackMessage ?? "준비중입니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 카테고리 읽기 (UI 표시용)
    final selected = ref.watch(categoryFilterProvider).category;

    // 필요하면 typeSeq도 이렇게 읽을 수 있음 (필터 API에 사용)
    // final typeSeq = ref.watch(categoryFilterProvider).typeSeq;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        children: [
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 24,
            childAspectRatio: 3.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _CategoryTile(
                icon: Icons.theater_comedy_outlined,
                title: "뮤지컬",
                isSelected: selected == TicketCategory.musical,
                onTap: () {
                  // 뮤지컬만 리스트 페이지 이동
                  _selectCategoryAndMove(
                    category: TicketCategory.musical,
                    goListPage: true,
                  );
                },
              ),
              _CategoryTile(
                icon: Icons.music_note_outlined,
                title: "콘서트",
                isSelected: selected == TicketCategory.concert,
                onTap: () {
                  _selectCategoryAndMove(
                    category: TicketCategory.concert,
                    goListPage: false,
                    snackMessage: "콘서트는 준비중입니다.",
                  );
                },
              ),
              _CategoryTile(
                icon: Icons.speaker_group_outlined,
                title: "연극",
                isSelected: selected == TicketCategory.play,
                onTap: () {
                  _selectCategoryAndMove(
                    category: TicketCategory.play,
                    goListPage: false,
                    snackMessage: "연극은 준비중입니다.",
                  );
                },
              ),
              _CategoryTile(
                icon: Icons.chair_alt_outlined,
                title: "클래식/무용",
                isSelected: selected == TicketCategory.classic,
                onTap: () {
                  _selectCategoryAndMove(
                    category: TicketCategory.classic,
                    goListPage: false,
                    snackMessage: "클래식/무용은 준비중입니다.",
                  );
                },
              ),
              _CategoryTile(
                icon: Icons.sports_baseball_outlined,
                title: "스포츠",
                isSelected: selected == TicketCategory.sports,
                onTap: () {
                  _selectCategoryAndMove(
                    category: TicketCategory.sports,
                    goListPage: false,
                    snackMessage: "스포츠는 준비중입니다.",
                  );
                },
              ),
              _CategoryTile(
                icon: Icons.park_outlined,
                title: "레저/캠핑",
                isSelected: selected == TicketCategory.leisure,
                onTap: () {
                  _selectCategoryAndMove(
                    category: TicketCategory.leisure,
                    goListPage: false,
                    snackMessage: "레저/캠핑은 준비중입니다.",
                  );
                },
              ),
              _CategoryTile(
                icon: Icons.museum_outlined,
                title: "전시/행사",
                isSelected: selected == TicketCategory.expo,
                onTap: () {
                  _selectCategoryAndMove(
                    category: TicketCategory.expo,
                    goListPage: false,
                    snackMessage: "전시/행사는 준비중입니다.",
                  );
                },
              ),
              _CategoryTile(
                icon: Icons.child_care_outlined,
                title: "아동/가족",
                isSelected: selected == TicketCategory.kids,
                onTap: () {
                  _selectCategoryAndMove(
                    category: TicketCategory.kids,
                    goListPage: false,
                    snackMessage: "아동/가족은 준비중입니다.",
                  );
                },
              ),
              _CategoryTile(
                icon: Icons.blur_on_outlined,
                title: "topping",
                isSelected: selected == TicketCategory.topping,
                onTap: () {
                  _selectCategoryAndMove(
                    category: TicketCategory.topping,
                    goListPage: false,
                    snackMessage: "topping은 준비중입니다.",
                  );
                },
              ),
              _CategoryTile(
                icon: Icons.card_giftcard_outlined,
                title: "이달의혜택",
                isSelected: selected == TicketCategory.benefit,
                onTap: () {
                  _selectCategoryAndMove(
                    category: TicketCategory.benefit,
                    goListPage: false,
                    snackMessage: "이달의혜택은 준비중입니다.",
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _MenuLine(title: "이벤트", onTap: () {}),
          _MenuLine(title: "MD shop", onTap: () {}),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? Colors.grey.shade100 : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(icon, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuLine extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _MenuLine({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
