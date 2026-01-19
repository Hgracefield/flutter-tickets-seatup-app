import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
// import 'package:seatup_app/view/user/category.dart';

class MainPageHome extends StatefulWidget {
  const MainPageHome({super.key});

  @override
  State<MainPageHome> createState() => _MainPageHomeState();
}

class _MainPageHomeState extends State<MainPageHome> {
  // Property
  int selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: MediaQuery.widthOf(context) - 20,
                  height: 350,
                  child: Swiper(
                    itemCount: 3,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          "images/musical0${index + 1}.jpg",
                          fit: BoxFit.cover,
                          alignment: AlignmentGeometry.topCenter,
                        ),
                      );
                    },
                    pagination: SwiperPagination(
                      builder: DotSwiperPaginationBuilder(
                        color: Colors.white38,
                        activeColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              //   child: Row(
              //     children: [
              //       TextButton(
              //         onPressed: () => Navigator.push(
              //           context,
              //           MaterialPageRoute(builder: (context) => Category(),)),
              //         child: Column(
              //           children: [
              //             Icon(
              //               Icons.theater_comedy,
              //               color: Colors.black,
              //               size: 50,
              //             ),
              //             Text(
              //               '뮤지컬',
              //               style: TextStyle(
              //                 color: Colors.black,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ],
              //         )
              //       ),
              //     ],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '장르별 랭킹',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    categoryButton('뮤지컬', 0),
                    categoryButton('콘서트', 1),
                    categoryButton('스포츠', 3),
                    categoryButton('전시/행사', 4),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.asset('images/main_banner1.jpg'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '베스트 관람후기',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  // Widget ---
  Widget categoryButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = index;
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedCategory == index
                  ? Colors.grey.shade900
                  : Colors.grey.shade300,
              width: 2,
            ),
            color: selectedCategory == index
                ? Colors.grey.shade900
                : Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selectedCategory == index
                  ? Colors.white
                  : Colors.grey.shade900,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

} // class
