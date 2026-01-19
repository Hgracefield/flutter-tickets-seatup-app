import 'package:flutter/material.dart';
import 'package:seatup_app/view/user/category.dart';
import 'package:seatup_app/view/user/curtain_search.dart';
import 'package:seatup_app/view/user/main_page_home.dart';
import 'package:seatup_app/view/user/user_mypage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  // property
  late TabController mainTabController;

  @override
  void initState() {
    super.initState();
    mainTabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: 2, // 홈 화면을 기본페이지로 설정
    );
    mainTabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    mainTabController.dispose();
    super.dispose();
  }

  AppBar mainAppBar(int index) {
    // 앱 바 메인화면에서 일괄 적용
    final titles = ['구매', '판매', 'SeatUp', '검색', 'MY티켓'];

    return AppBar(
      title: Text(titles[index], style: TextStyle(fontWeight: FontWeight.w500)),
      centerTitle: true,
      backgroundColor: Colors.white,
      toolbarHeight: 70,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      actions: [
        IconButton(
          onPressed: () {
            //
          },
          icon: Icon(Icons.notifications_outlined),
        ),
        IconButton(
          onPressed: () {
            //
          },
          icon: Icon(Icons.chat_bubble_outline),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: mainAppBar(mainTabController.index),
      body: TabBarView(
        controller: mainTabController,
        children: [Category(), Category(), MainPageHome(), CurtainSearch(), UserMypage()],
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
