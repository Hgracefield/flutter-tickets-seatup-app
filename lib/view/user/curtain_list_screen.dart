import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/user/ticket_list_option.dart';

import '../../vm/curtain_list_provider.dart';
import '../../vm/category_provider.dart'; // categoryFilterProvider 사용
import '../../model/curtain_list.dart' as model;

class CurtainListScreen extends ConsumerStatefulWidget {
  const CurtainListScreen({super.key});

  @override
  ConsumerState<CurtainListScreen> createState() =>
      _CurtainListScreenState();
}

class _CurtainListScreenState
    extends ConsumerState<CurtainListScreen> {
  bool _isSearching = false;

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 선택된 카테고리를 텍스트로 변환 (AppBar 제목용)
  String _categoryTitle(TicketCategory? category) {
    switch (category) {
      case TicketCategory.musical:
        return "뮤지컬";
      case TicketCategory.concert:
        return "콘서트";
      case TicketCategory.play:
        return "연극";
      case TicketCategory.classic:
        return "클래식/무용";
      case TicketCategory.expo:
        return "전시/행사";
      case TicketCategory.sports:
        return "스포츠";
      case TicketCategory.leisure:
        return "레저/캠핑";
      case TicketCategory.kids:
        return "아동/가족";
      case TicketCategory.topping:
        return "topping";
      case TicketCategory.benefit:
        return "이달의혜택";
      default:
        return "공연";
    }
  }

  void _startSearchMode() {
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  Future<void> _stopSearchMode(int? typeSeq) async {
    setState(() => _isSearching = false);
    _searchController.clear();

    // 검색 초기화 (typeSeq 기준 리스트로 복구)
    // family provider를 안 쓰는 구조라 typeSeq는 provider 내부(categoryFilterProvider)에서 자동 적용됨
    await ref.read(curtainListProvider.notifier).clearSearch();
  }

  Future<void> _doSearch(int? typeSeq) async {
    final keyword = _searchController.text.trim();

    if (keyword.isEmpty) {
      await ref.read(curtainListProvider.notifier).clearSearch();
    } else {
      await ref.read(curtainListProvider.notifier).search(keyword);
    }
  }

  PreferredSizeWidget _buildAppBar({
    required String titleText,
    required int? typeSeq,
  }) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.pop(context),
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "공연명을 검색하세요",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) async => _doSearch(typeSeq),
            )
          : Text(
              titleText,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
      centerTitle: true,
      actions: [
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearchMode,
          )
        else ...[
          IconButton(
            tooltip: "검색 실행",
            icon: const Icon(Icons.search),
            onPressed: () async => _doSearch(typeSeq),
          ),
          IconButton(
            tooltip: "검색 닫기",
            icon: const Icon(Icons.close),
            onPressed: () async => _stopSearchMode(typeSeq),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // categoryFilterProvider에서 category + typeSeq 읽기
    final filter = ref.watch(categoryFilterProvider);
    final typeSeq = filter.typeSeq;
    final titleText = _categoryTitle(filter.category);

    // typeSeq에 맞는 provider를 watch (family provider)
    // family provider 제거했기 때문에 curtainListProvider만 watch하면 됨
    // 필터(typeSeq)는 curtainListProvider 내부에서 categoryFilterProvider를 watch해서 자동 반영됨
    final asyncList = ref.watch(curtainListProvider);

    return Scaffold(
      appBar: _buildAppBar(titleText: titleText, typeSeq: typeSeq),
      body: asyncList.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text("공연 데이터가 없습니다."));
          }

          return RefreshIndicator(
            onRefresh: () async {
              // typeSeq 기반 새로고침
              // family provider를 안 쓰는 구조라 typeSeq는 provider 내부에서 자동 적용됨
              await ref.read(curtainListProvider.notifier).refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 2),
              itemCount: list.length,
              itemBuilder: (_, index) {
                final model.CurtainList item = list[index];

                return _CurtainCard(
                  item: item,
                  onTap: () {
                    FocusScope.of(context).unfocus();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketListOption(item: item),
                      ),
                    );

                    debugPrint("클릭한 curtain_id = ${item.curtain_id}");
                  },
                );
              },
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("에러: $e")),
      ),
    );
  }
}

class _CurtainCard extends StatelessWidget {
  final model.CurtainList item;
  final VoidCallback onTap;

  const _CurtainCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: 3,
          vertical: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  item.curtain_pic,
                  width: 90,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 90,
                      height: 120,
                      alignment: Alignment.center,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title_contents,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (item.place_name.isNotEmpty)
                        Text(
                          item.place_name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
