import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../vm/curtain_list_provider.dart';
import '../../model/curtain_list.dart' as model;

class CurtainList extends ConsumerStatefulWidget {
  const CurtainList({super.key});

  @override
  ConsumerState<CurtainList> createState() => _CurtainListState();
}

class _CurtainListState extends ConsumerState<CurtainList> {
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

  void _startSearchMode() {
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  Future<void> _stopSearchMode() async {
    setState(() => _isSearching = false);
    _searchController.clear();
    await ref.read(curtainListProvider.notifier).clearSearch();
  }

  Future<void> _doSearch() async {
    final keyword = _searchController.text.trim();

    // 빈 값이면 전체 리스트로 복귀
    if (keyword.isEmpty) {
      await ref.read(curtainListProvider.notifier).clearSearch();
    } else {
      await ref.read(curtainListProvider.notifier).search(keyword);
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () {
          Navigator.pop(context);
        },
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
              onSubmitted: (_) async {
                //  엔터 누르면 검색
                await _doSearch();
              },
            )
          : const Text("뮤지컬",style: TextStyle(fontWeight: FontWeight.w700),),centerTitle:true ,
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
            onPressed: () async {
              //  버튼 눌러서 검색
              await _doSearch();
            },
          ),
          
          IconButton(
            tooltip: "검색 닫기",
            icon: const Icon(Icons.close),
            onPressed: () async {
              await _stopSearchMode();
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(curtainListProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: asyncList.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text("공연 데이터가 없습니다."));
          }

          return RefreshIndicator(
            onRefresh: () async {
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) =>
                    //         NextPage(curtainId: item.curtain_id),
                    //   ),
                    // );

                    //  curtain_id 넘겨서 상세/판매/구매로 이동하면 됨
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
                      ),SizedBox(height: 2,),
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
