import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain.dart';
import 'package:seatup_app/model/curtain_list.dart';
import 'package:seatup_app/util/textfield_form.dart';
import 'package:seatup_app/view/user/ticket_list_option.dart';
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
  late List<Curtain> curtainList;
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
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
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextfieldForm.suTextField(
                controller: searchController,
                hintText: '공연을 검색해보세요',
                keyboardType: TextInputType.text,
                onSubmitted: (value) async{
                  search();
                },prefixIcon: Icons.search),
              // _buildTextField(searchController, '공연을 검색해보세요'),
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
                    return _buildCurtainCard(curtainList[index], () {
                      FocusScope.of(context).unfocus();
                    print('sdsdsdsdsd');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        CurtainList item = CurtainList(
                          curtain_id: curtainList[index].curtain_id!, 
                          title_seq: curtainList[index].curtain_id!, 
                          title_contents: curtainList[index].curtain_title, 
                          curtain_pic: curtainList[index].curtain_pic, 
                          place_name: curtainList[index].curtain_place); 
                        
                        return TicketListOption(item: item);
                      },));

                        // builder: (_) => TicketListOption(item: curtainList[index]),
                      // ),
                    // );

                    // debugPrint("클릭한 curtain_id = ${item.curtain_id}");
                    },);
                  },),
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  // === Widgets ===

  // Widget _buildTextField(TextEditingController controller, String msg) {
  //   return TextField(
  //     controller: searchController,
  //     keyboardType: TextInputType.emailAddress,
  //     onSubmitted: (value) async {
  //       // 검색
  //       search();
  //     },
  //     decoration: InputDecoration(
  //       hintText: msg,
  //       hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
  //       contentPadding: const EdgeInsets.symmetric(
  //         horizontal: 20,
  //         vertical: 16,
  //       ),
  //       filled: true,
  //       prefixIcon: Icon(Icons.search, color: Colors.grey),
  //       fillColor: const Color(0xFFF8F8F8),

  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide.none,
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: const BorderSide(color: Colors.black, width: 1),
  //       ),
  //       errorBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: const BorderSide(color: Colors.red, width: 1),
  //       ),
  //       focusedErrorBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: const BorderSide(color: Colors.red, width: 1),
  //       ),
  //     ),
  //   );
  // } // _buildTextField



  Widget _buildCurtainCard(Curtain item, VoidCallback onTap)
  {
    return GestureDetector(
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
                          item.curtain_title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (item.curtain_place.isNotEmpty)
                          Text(
                            item.curtain_place,
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
