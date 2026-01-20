import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
// import 'package:seatup_app/view/user/category.dart';
import 'package:http/http.dart' as http;
import 'package:seatup_app/constants/api_keys.dart';
import 'package:seatup_app/model/weather.dart';

class MainPageHome extends StatefulWidget {
  const MainPageHome({super.key});

  @override
  State<MainPageHome> createState() => _MainPageHomeState();
}

class _MainPageHomeState extends State<MainPageHome> {
  // Property
  int selectedCategory = 0; // 선택한 카테고리 인덱스
  WeatherModel? weather; // 날씨 데이터를 담을 모델

  @override
  void initState() {
    super.initState();
    fetchWeather(); // 화면 실행 시 기상청 API 호출
  }

  // Functions ---
  Future<void> fetchWeather() async {
    // 기상청 API
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
        weather = WeatherModel.fromJson(data);
      });
    } else {
      throw Exception('날씨 데이터 로딩 실패');
    }
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
                          "images/musical${index + 1}.jpg",
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
              
              // Text('기온: ${weather?.temperature ?? "-"}°C'),
              Text('최저 기온: ${weather?.tmn ?? "-"}°C'),
              Text('최고 기온: ${weather?.tmx ?? "-"}°C'),
              Text('1시간 기온: ${weather?.tmp ?? "-"}°C'),
              // Text('습도: ${weather?.humidity ?? "-"}°C'),
              Text('하늘: ${weather?.sky ?? "-"}°C'),
              Text('강수 확률: ${weather?.pop ?? "-"}'),
              Text('강수 형태: ${weather?.pty ?? "-"}'),
              Text('1시간 강수량: ${weather?.pcp ?? "-"}'),
              Text('1시간 신적설: ${weather?.sno ?? "-"}'),

              weather == null
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            color: Colors.lightBlue[50],
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Text(
                                    '${weather!.temperature}°C',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '하늘: ${weather!.sky ?? "-"}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '습도: ${weather!.humidity ?? "-"}%',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '강수: ${weather!.pty ?? "-"}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '오늘의 날씨',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 여기서 추가 예보 카드나 다른 정보 추가 가능
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              weatherCard(
                                '체감온도',
                                '${weather!.temperature}°C',
                                Icons.thermostat,
                              ),
                              weatherCard(
                                '습도',
                                '${weather!.humidity ?? "-"}%',
                                Icons.water_drop,
                              ),
                              weatherCard(
                                '강수',
                                '${weather!.pty ?? "-"}',
                                Icons.grain,
                              ),
                            ],
                          ),
                        ],
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget weatherCard(String title, String text, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
} // class
