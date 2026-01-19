import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
// import 'package:seatup_app/view/user/category.dart';
import 'package:http/http.dart' as http;
import 'package:seatup_app/constants/api_keys.dart';

class MainPageHome extends StatefulWidget {
  const MainPageHome({super.key});

  @override
  State<MainPageHome> createState() => _MainPageHomeState();
}

class _MainPageHomeState extends State<MainPageHome> {
  // Property
  int selectedCategory = 0; // 선택한 카테고리 인덱스
  Map<String, dynamic>? weather; // 날씨 데이터를 담을 그릇

  @override
  void initState() {
    super.initState();
    fetchWeather(); // 화면 실행 시 기상청 API 호출
  }

  // Functions ---
  Future<void> fetchWeather() async { // 기상청 API
    const url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0';

    final uri = Uri.parse(
      '$url/getVilageFcst' // URL -> 단기예보조회
      '?serviceKey=$weatherServiceKey' // 인증키
      '&pageNo=1' // 페이지 번호
      '&numOfRows=10' // 한 페이지 결과 수
      '&dataType=JSON' // 요청자료형식(XML/JSON)
      '&base_date=20260119' // 작성 기준 날짜
      '&base_time=1400' // 작성 기준 시간
      '&nx=61' // 예보지점의 X 좌표값 -> 강남구
      '&ny=126', // 예보지점의 Y 좌표값 -> 강남구
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print(data);
      setState(() {
        weather = data;
      });
    } else {
      // throw Exception('기상청 API 실패: ${response.statusCode}');
      throw Exception('날씨 데이터 로딩 실패');
    }
  }

  String? getWeatherValue(String category) { // 특정 날씨 데이터 추출
    if (weather == null) {
      return null;
    }

    final List items =
      weather!['response']['body']['items']['item'];

    for (final item in items) {
      if (item['category'] == category) {
        return item['fcstValue']?.toString();
      }
    }

    return null;
  }

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
