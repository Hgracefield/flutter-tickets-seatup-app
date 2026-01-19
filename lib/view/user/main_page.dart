import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/user/curtain_search.dart';
import 'package:seatup_app/view/user/user_to_user_chat.dart';
import 'package:seatup_app/vm/storage_provider.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 70,
        title: Text('SeatUp'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CurtainSearch()),
              );
            },
            icon: Icon(Icons.search),
          ),
          IconButton(             // 채팅확인용으로 만들음
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => UserToUserChat(
                  roomId: '2_3', 
                  partnerName: '고석민', 
                  partnerId: '3'),));
            }, 
            icon: Icon(Icons.chat)
          )
        ],
      ),
      body: TabBarView(
        controller: mainTabController,
        children: [
          Category(),
          Category(),
          MainPageHome(),
          CurtainSearch(),
          UserMypage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        height: 80,
        child: TabBar(
          controller: mainTabController,
          labelColor: const Color.fromARGB(255, 0, 0, 0),
          labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          indicatorColor: const Color.fromARGB(255, 0, 0, 0),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 2,
          tabs: [
            Tab(icon: Icon(Icons.shopping_cart_outlined), text: '구매'),
            Tab(icon: Icon(Icons.sell_outlined), text: '판매'),
            Tab(icon: Icon(Icons.home), text: '홈'),
            Tab(icon: Icon(Icons.search_outlined), text: '검색'),
            Tab(icon: Icon(Icons.person_outline_outlined), text: '마이'),
          ],
        ),
      ),
    );
  }
}
