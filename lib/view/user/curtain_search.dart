import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/vm/curtain_notifier.dart';
import 'package:seatup_app/vm/keyword_notifier.dart';

class CurtainSearch extends ConsumerStatefulWidget {
  const CurtainSearch({super.key});

  @override
  ConsumerState<CurtainSearch> createState() => _CurtainSearchState();
}

class _CurtainSearchState extends ConsumerState<CurtainSearch> {
  // === Property ===

  late TextEditingController searchController;
  late bool isShowSearchResult;
  late List<Curtain> curtainList;
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    isShowSearchResult = false;
    curtainList = [];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keywordAsync = ref.watch(keywordHandlerNotifilerProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '검색',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildTextField(searchController, '공연을 검색해보세요'),
              keywordAsync.when(
                data: (data) {
                  return data.isEmpty
                      ? Center(child: Text('검색 기록이 없어요'))
                      : SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  searchController.text = data[index];
                                  search();
                                },
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey[200],
                                    ),
                                    child: Center(child: Text(data[index])),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
                error: (error, stackTrace) => Center(child: Text('정검 중')),
                loading: () => Center(child: CircularProgressIndicator()),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: curtainList.isEmpty
                ? SizedBox.shrink()
                : ListView.builder(
                  itemCount: curtainList.length,
                  itemBuilder: (context, index) {
                    return Card(child: Text(curtainList[index].curtain_title));
                  },),
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  // === Widgets ===

  Widget _buildTextField(TextEditingController controller, String msg) {
    return TextField(
      controller: searchController,
      keyboardType: TextInputType.emailAddress,
      onSubmitted: (value) async {
        // 검색
        search();
      },
      decoration: InputDecoration(
        hintText: msg,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        filled: true,
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        fillColor: const Color(0xFFF8F8F8),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  } // _buildTextField

  // === Functions ===

  Future search() async {
    String keyword = searchController.text.trim();
    if (keyword.isNotEmpty) {
      final keywordNotifier = ref.read(
        keywordHandlerNotifilerProvider.notifier,
      );
      int count = await keywordNotifier.existKeyword(keyword);
      if (count > 0) {
        await keywordNotifier.updateKeyword(keyword);
      } else {
        await keywordNotifier.insertKeyword(searchController.text.trim());
      }
      curtainList = await ref.read(curtainNotifierProvider.notifier).searchCurtain(keyword);
      setState(() {
        
      });
    }
  }
}
