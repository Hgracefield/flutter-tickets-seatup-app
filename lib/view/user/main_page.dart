import 'package:card_swiper/card_swiper.dart';
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
      appBar: AppBar(
        title: Text('SeatUp'),
        centerTitle: true,
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
      body: SizedBox(
        width: MediaQuery.widthOf(context),
        height: 300,
        child: Swiper(
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) {
            return Image.asset("images/musical01.jpg", fit: BoxFit.cover);
          },
          pagination: SwiperPagination(),
          control: SwiperControl(),
        ),
      ),
    );
  }
}
