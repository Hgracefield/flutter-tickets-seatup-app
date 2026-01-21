import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
// import 'package:seatup_app/view/user/category.dart';
import 'package:http/http.dart' as http;
// import 'package:seatup_app/constants/api_keys.dart';
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
    // fetchWeather(); // 화면 실행 시 기상청 API 호출
  }

  // // Functions ---
  // Future<void> fetchWeather() async {
  //   // 기상청 API
  //   const url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0';

  //   final uri = Uri.parse(
  //     '$url/getVilageFcst' // URL -> 단기예보조회
  //     // '?serviceKey=$weatherServiceKey' // 인증키
  //     '&pageNo=1' // 페이지 번호
  //     '&numOfRows=10' // 한 페이지 결과 수
  //     '&dataType=JSON' // 요청자료형식(XML/JSON)
  //     '&base_date=20260119' // 작성 기준 날짜
  //     '&base_time=1400' // 작성 기준 시간
  //     '&nx=61' // 예보지점의 X 좌표값 -> 강남구
  //     '&ny=126', // 예보지점의 Y 좌표값 -> 강남구
  //   );

  //   final response = await http.get(uri);

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(utf8.decode(response.bodyBytes));
  //     print(data);
  //     setState(() {
  //       weather = data;
  //     });
  //   } else {
  //     // throw Exception('기상청 API 실패: ${response.statusCode}');
  //     throw Exception('날씨 데이터 로딩 실패');
  //   }
  // }

  // String? getWeatherValue(String category) {
  //   // 특정 날씨 데이터 추출
  //   if (weather == null) {
  //     return null;
  //   }

  //   final List items = weather!['response']['body']['items']['item'];

  //   for (final item in items) {
  //     if (item['category'] == category) {
  //       return item['fcstValue']?.toString();
  //     }
  //   }

  //   return null;
  // }

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
                    _categoryButton('뮤지컬', 0),
                    _categoryButton('콘서트', 1),
                    _categoryButton('스포츠', 3),
                    _categoryButton('전시/행사', 4),
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

              // Text('1시간 기온: ${weather?.tmp ?? "-"}°C'),
              // Text('최저 기온: ${weather?.tmn ?? "-"}°C'),
              // Text('최고 기온: ${weather?.tmx ?? "-"}°C'),
              // Text('습도: ${weather?.reh ?? "-"}%'),
              // Text('하늘: ${weather?.sky ?? "-"}'),
              // Text('강수 형태: ${weather?.pty ?? "-"}'),
              // Text('강수 확률: ${weather?.pop ?? "-"}%'),
              // Text('1시간 강수량: ${weather?.pcp ?? "-"}mm'),
              // Text('1시간 신적설: ${weather?.sno ?? "-"}cm'),

              weather == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _mainWeatherCard(weather!),
                          const SizedBox(height: 16),
                          _minMaxTempCard(weather!),
                          const SizedBox(height: 16),
                          _weatherInfoGrid(weather!),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  } // build

  // --- Widgets ---

  // 카테고리 버튼
  Widget _categoryButton(String title, int index) {
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
  } // categoryButton

  // 메인 날씨 카드 (기온 + 하늘)
  Widget _mainWeatherCard(WeatherModel weather) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _skyColor(weather.sky),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(_skyIcon(weather.sky), size: 60, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            '${weather.tmp ?? "-"}°C',
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _skyText(weather.sky),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  } // _mainWeatherCard

  // 날씨 최저 / 최고 기온 카드
  Widget _minMaxTempCard(WeatherModel weather) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _tempItem('최저', weather.tmn, Icons.arrow_downward),
            _tempItem('최고', weather.tmx, Icons.arrow_upward),
          ],
        ),
      ),
    );
  }

  Widget _tempItem(String label, String? value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          '${value ?? "-"}°C',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
  // _minMaxTempCard

  // 날씨 정보 그리드
  Widget _weatherInfoGrid(WeatherModel weather) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: [
        _infoTile('습도', '${weather.reh ?? "-"}%', Icons.water_drop),
        _infoTile('강수확률', '${weather.pop ?? "-"}%', Icons.umbrella),
        _infoTile('강수형태', _ptyText(weather.pty), Icons.grain),
        _infoTile('강수량', '${weather.pcp ?? "-"}mm', Icons.cloud),
        _infoTile('적설', '${weather.sno ?? "-"}cm', Icons.ac_unit),
      ],
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: Colors.blue),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
  // _weatherInfoGrid


  // --- Functions ---

  // 날씨 상태값 변환
  Color _skyColor(String? sky) {
    switch (sky) {
      case '1':
        return Colors.blue; // 맑음
      case '3':
        return Colors.grey; // 구름 많음
      case '4':
        return Colors.blueGrey; // 흐림
      default:
        return Colors.black26;
    }
  }

  IconData _skyIcon(String? sky) {
    switch (sky) {
      case '1':
        return Icons.wb_sunny;
      case '3':
        return Icons.cloud;
      case '4':
        return Icons.cloud_queue;
      default:
        return Icons.help_outline;
    }
  }

  String _skyText(String? sky) {
    switch (sky) {
      case '1':
        return '맑음';
      case '3':
        return '구름 많음';
      case '4':
        return '흐림';
      default:
        return '정보 없음';
    }
  }

  String _ptyText(String? pty) {
    switch (pty) {
      case '0':
        return '없음';
      case '1':
        return '비';
      case '2':
        return '비/눈';
      case '3':
        return '눈';
      default:
        return '-';
    }
  }

} // class
