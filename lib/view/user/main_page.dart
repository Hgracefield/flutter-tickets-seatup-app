import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:seatup_app/view/user/search_result.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SeatUp'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchResult()),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.widthOf(context),
        height: 300,
        child: Swiper(
          itemCount: 3,
          itemBuilder: (BuildContext context,int index){
            return Image.asset(
              "images/musical01.jpg",
              fit: BoxFit.cover,
            );
          },
          pagination: SwiperPagination(),
          control: SwiperControl(),
        ),
      ),
    );
  }
}
