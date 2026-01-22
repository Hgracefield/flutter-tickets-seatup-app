import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/view/user/map_view.dart';
import 'package:seatup_app/view/user/purchase_history.dart';
import 'package:seatup_app/view/user/review_list.dart';
import 'package:seatup_app/view/user/sell_history.dart';
import 'package:seatup_app/view/user/sell_register.dart';
import 'package:seatup_app/view/user/seller_to_admin_chat.dart';
import 'package:seatup_app/view/user/transaction_review_list.dart';
import 'package:seatup_app/view/user/user_chat_list.dart';
import 'package:seatup_app/view/user/user_login.dart';
import 'package:seatup_app/view/user/user_to_user_chat.dart';
import 'package:seatup_app/view/widgets/logout_button.dart';
import 'package:seatup_app/view/widgets/my_greeting_banner.dart';
import 'package:seatup_app/view/widgets/my_page_menu.dart';
import 'package:seatup_app/vm/route_vm.dart';
import 'package:seatup_app/vm/storage_provider.dart';

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SellerToAdminChat(),
            ),
          );
        },
      ),
      body: ListView(
        children: [
          const MyGreetingBanner(),
          const SizedBox(height: 10),

          Container(
            color: Colors.white,

            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  child: MyPageMenuSection(
                    title: "내가 구매한 상품",
                    items: [
                      MyPageMenuItemData(
                        text: "구매 이력 관리",
                        onTap:() => _push(PurchaseHistory()),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1, color: Color(0xFFE6E6E6)),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  child: MyPageMenuSection(
                    title: "내가 판매한 상품",
                    items: [
                      MyPageMenuItemData(text: "판매 등록", onTap: () => _push(SellRegister())),
                      MyPageMenuItemData(text: "판매 내역", onTap: () => _push(SellHistory())),
                    ],
                  ),
                ),
                const Divider(thickness: 1, color: Color(0xFFE6E6E6)),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  child: MyPageMenuSection(
                    title: "",
                    items: [
                      MyPageMenuItemData(
                        text: "거래 채팅 리스트",
                        onTap: () => _push(UserChatList())
                      ),

                      MyPageMenuItemData(text: "관람 후기", onTap: () => 
                      _push(ReviewList())),
                      MyPageMenuItemData(text: "거래 후기", onTap: () =>
                      _push(TransactionReviewList())),
                    ],
                  ),
                ),
                const Divider(thickness: 1, color: Color(0xFFE6E6E6)),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  child: MyPageMenuSection(
                    title: "회원정보",
                    items: [
                      MyPageMenuItemData(
                        text: "회원정보수정",
                        onTap: () {},// 페이지 없어서 보기좋게 넣어놓기만함
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
                final box = ref.read(storageProvider);

                box.remove('userIsLogin');
                box.remove('user_id');
                box.remove('user_name');
                box.remove('user_email');

                // 로그인 페이지로 이동 뒤로가기 방지
                Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (_) => const UserLogin()),
                (route) => false,);
              },
            ),
          ),
           const SizedBox(height: 10),
        
         
          
          

          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 20,
              ),
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
                  ),

                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
