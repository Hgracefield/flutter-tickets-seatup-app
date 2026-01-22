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
  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedCategoryProvider);

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
                  //  Riverpod 상태 저장
                  ref.read(selectedCategoryProvider.notifier).state =
                      TicketCategory.musical;

                  //  CurtainList 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CurtainListScreen(),
                    ),
                  );
                },
              ),

              _CategoryTile(
                icon: Icons.music_note_outlined,
                title: "콘서트",
                isSelected: selected == TicketCategory.concert,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      TicketCategory.concert;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("콘서트는 준비중입니다 🙂")),
                  );
                },
              ),

              _CategoryTile(
                icon: Icons.speaker_group_outlined,
                title: "연극",
                isSelected: selected == TicketCategory.play,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      TicketCategory.play;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("연극은 준비중입니다 🙂")),
                  );
                },
              ),

              _CategoryTile(
                icon: Icons.chair_alt_outlined,
                title: "클래식/무용",
                isSelected: selected == TicketCategory.classic,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      TicketCategory.classic;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("클래식/무용은 준비중입니다 🙂"),
                    ),
                  );
                },
              ),

              _CategoryTile(
                icon: Icons.sports_baseball_outlined,
                title: "스포츠",
                isSelected: selected == TicketCategory.sports,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      TicketCategory.sports;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("스포츠는 준비중입니다 🙂")),
                  );
                },
              ),

              _CategoryTile(
                icon: Icons.park_outlined,
                title: "레저/캠핑",
                isSelected: selected == TicketCategory.leisure,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      TicketCategory.leisure;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("레저/캠핑은 준비중입니다 🙂")),
                  );
                },
              ),

              _CategoryTile(
                icon: Icons.museum_outlined,
                title: "전시/행사",
                isSelected: selected == TicketCategory.expo,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      TicketCategory.expo;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("전시/행사는 준비중입니다 🙂")),
                  );
                },
              ),

              _CategoryTile(
                icon: Icons.child_care_outlined,
                title: "아동/가족",
                isSelected: selected == TicketCategory.kids,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      TicketCategory.kids;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("아동/가족은 준비중입니다 🙂")),
                  );
                },
              ),

              _CategoryTile(
                icon: Icons.blur_on_outlined,
                title: "topping",
                isSelected: selected == TicketCategory.topping,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      TicketCategory.topping;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("topping은 준비중입니다 🙂"),
                    ),
                  );
                },
              ),

              _CategoryTile(
                icon: Icons.card_giftcard_outlined,
                title: "이달의혜택",
                isSelected: selected == TicketCategory.benefit,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      TicketCategory.benefit;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("이달의혜택은 준비중입니다 🙂")),
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
