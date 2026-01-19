import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/widgets/logout_button.dart';
import 'package:seatup_app/view/widgets/my_greeting_banner.dart';
import 'package:seatup_app/view/widgets/my_page_menu.dart';



class UserMypage extends ConsumerStatefulWidget {
  const UserMypage({super.key});

  @override
  ConsumerState<UserMypage> createState() => _UserMypageState();
}

class _UserMypageState extends ConsumerState<UserMypage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("MY티켓"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body:
       ListView(
        
        children: [
          const MyGreetingBanner(),
          const SizedBox(height: 10),

          Container(
            color: Colors.white,

            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                  child: MyPageMenuSection(
                    title: "내가 구매한 상품",
                    items: [
                      MyPageMenuItemData(
                        text: "구매 이력 관리",
                        onTap: () {
                          // TODO: 구매 이력 관리 화면 이동
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0xFFE6E6E6),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                  child: MyPageMenuSection(
                    title: "내가 판매한 상품",
                    items: [
                      MyPageMenuItemData(
                        text: "판매관리",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0xFFE6E6E6),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                  child: MyPageMenuSection(
                    title: "",
                    items: [
                      MyPageMenuItemData(
                        text: "1:1 문의하기",
                        onTap: () {},
                      ),
                      MyPageMenuItemData(
                        text: "1:1 문의 내역",
                        onTap: () {},
                      ),
                      MyPageMenuItemData(
                        text: "나의 후기",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0xFFE6E6E6),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                  child: MyPageMenuSection(
                    title: "회원정보",
                    items: [
                      MyPageMenuItemData(
                        text: "회원정보수정",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LogoutButton(
              onTap: () {
                // TODO: 로그아웃 처리
              },
            ),
          ),

          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "고객센터 | 1644-0633",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "운영시간 : 09:00 ~ 22:00 (평일/주말/공휴일)\n점심시간 : 12:00 ~ 13:00",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
