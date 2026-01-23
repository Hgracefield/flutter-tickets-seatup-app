import 'package:flutter/material.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/util/text_form.dart';
import 'package:seatup_app/view/user/category.dart';
import 'package:seatup_app/view/user/curtain_search.dart';
import 'package:seatup_app/view/user/main_page_home.dart';
import 'package:seatup_app/view/user/user_chat_list.dart';
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
      initialIndex: 2, // 홈 화면을 기본 페이지로 설정
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

  // 메인 페이지에서 앱 바 일괄 적용
  AppBar mainAppBar(int index) {
    final List<Widget> titles = [
      TextForm.suAppText(text: '카테고리'),
      TextForm.suAppText(text: '카테고리'),
      Image.asset('images/su_app_icon.png', width: 110),
      TextForm.suAppText(text: '검색'),
      TextForm.suAppText(text: 'MY티켓'),
    ];

    return AppBar(
      title: titles[index],
      centerTitle: true,
      backgroundColor: Colors.white,
      toolbarHeight: 70,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.sublack),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserChatList()),
          ),
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
          labelColor: AppColors.suyellow,
          labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          indicatorColor: AppColors.suyellow,
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
