import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/weather.dart';
import 'package:seatup_app/view/user/curtain_list_screen.dart';
import 'package:seatup_app/vm/weather_provider.dart';

class MainPageHome extends ConsumerWidget {
  const MainPageHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider); // 날씨 데이터 저장
    // final selectedCategory = ref.watch(selectedCategoryProvider); // 선택한 카테고리

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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(20, 0, 10, 20),
                child: Row(
                  children: [
                    CategoryButton(
                      icon: Icons.theater_comedy_outlined,
                      label: '뮤지컬',
                      page: CurtainListScreen(),
                    ),
                    CategoryButton(
                      icon: Icons.music_note_outlined,
                      label: '콘서트',
                      comingSoon: true,
                    ),
                    CategoryButton(
                      icon: Icons.speaker_group_outlined,
                      label: '연극',
                      comingSoon: true,
                    ),
                    CategoryButton(
                      icon: Icons.chair_alt_outlined,
                      label: '클래식/무용',
                      comingSoon: true,
                    ),
                    CategoryButton(
                      icon: Icons.sports_baseball_outlined,
                      label: '스포츠',
                      comingSoon: true,
                    ),
                    CategoryButton(
                      icon: Icons.park_outlined,
                      label: '레저/캠핑',
                      comingSoon: true,
                    ),
                    CategoryButton(
                      icon: Icons.museum_outlined,
                      label: '전시/행사',
                      comingSoon: true,
                    ),
                    CategoryButton(
                      icon: Icons.child_care_outlined,
                      label: '아동/가족',
                      comingSoon: true,
                    ),
                    CategoryButton(
                      icon: Icons.blur_on_outlined,
                      label: 'topping',
                      comingSoon: true,
                    ),
                    CategoryButton(
                      icon: Icons.card_giftcard_outlined,
                      label: '이달의혜택',
                      comingSoon: true,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _title('장르별 랭킹'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // _categoryTab('뮤지컬', 0),
                    // _categoryTab('콘서트', 1),
                    // _categoryTab('연극', 3),
                    // _categoryTab('클래식/무용', 4),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.asset('images/main_banner1.jpg'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _title('베스트 관람후기'),
              ),
              weatherAsync.when(
                data: (weather) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        _title('오늘의 날씨'),
                        const SizedBox(height: 20),
                        _mainWeatherCard(weather),
                        const SizedBox(height: 10),
                        // _minMaxTempCard(weather!),
                        // const SizedBox(height: 20),
                        _weatherInfoGrid(weather),
                      ],
                    ),
                  );
                },
                error: (error, _) => const Text('날씨 정보를 불러오지 못했어요'),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  // --- Widgets ---
  // 타이틀 위젯
  Widget _title(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // 카테고리 탭
  // Widget _categoryTab(String title, int index) {
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: () {
  //         setState(() {
  //           selectedCategory = index;
  //         });
  //       },
  //       child: Container(
  //         margin: const EdgeInsets.symmetric(horizontal: 4),
  //         padding: const EdgeInsets.symmetric(vertical: 10),
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //           border: Border.all(
  //             color: selectedCategory == index
  //                 ? Colors.grey.shade900
  //                 : Colors.grey.shade300,
  //             width: 2,
  //           ),
  //           color: selectedCategory == index
  //               ? Colors.grey.shade900
  //               : Colors.white,
  //           borderRadius: BorderRadius.circular(50),
  //         ),
  //         child: Text(
  //           title,
  //           style: TextStyle(
  //             color: selectedCategory == index
  //                 ? Colors.white
  //                 : Colors.grey.shade900,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // } // categoryButton

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
          Icon(_skyIcon(weather.sky), size: 50, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            '${weather.tmp ?? "-"}°C',
            style: const TextStyle(
              fontSize: 28,
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

  // 날씨 최저 / 최고 기온 카드 (추후 적용 예정)
  // Widget _minMaxTempCard(WeatherModel weather) {
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 16),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           _tempItem('최저', weather.tmn, Icons.arrow_downward),
  //           _tempItem('최고', weather.tmx, Icons.arrow_upward),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _tempItem(String label, String? value, IconData icon) {
  //   return Column(
  //     children: [
  //       Icon(icon, color: Colors.blue),
  //       const SizedBox(height: 4),
  //       Text(
  //         '${value ?? "-"}°C',
  //         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //       Text(label, style: const TextStyle(color: Colors.grey)),
  //     ],
  //   );
  // }
  // _minMaxTempCard

  // 날씨 정보 그리드
  Widget _weatherInfoGrid(WeatherModel weather) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: [
        // _infoTile('습도', '${weather.reh ?? "-"}%', Icons.water_drop),
        _infoTile('강수확률', '${weather.pop ?? "-"}%', Icons.umbrella),
        _infoTile('강수형태', _ptyText(weather.pty), Icons.grain),
        _infoTile('강수량', '${weather.pcp ?? "-"}', Icons.cloud),
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
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
  // _weatherInfoGrid

  // --- Functions ---
  // 날씨 상태값 변환
  Color _skyColor(String? sky) {
    // 메인 날씨 카드 배경색
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
    // 메인 날씨 카드 아이콘
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
    // 메인 날씨 카드 텍스트
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
    // 강수 형태 value 텍스트
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

// 카테고리 버튼 위젯
class CategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? page;
  final bool comingSoon;

  const CategoryButton({
    super.key,
    required this.icon,
    required this.label,
    this.page,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: TextButton(
        onPressed: () {
          if (comingSoon) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('준비중입니다 🙂'),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
          }
        },
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
