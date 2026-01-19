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

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
