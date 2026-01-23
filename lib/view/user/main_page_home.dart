import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seatup_app/model/curtain_review.dart';
import 'package:seatup_app/model/weather.dart';
import 'package:seatup_app/util/color.dart';
import 'package:seatup_app/view/user/curtain_list_screen.dart';
import 'package:seatup_app/view/user/review_write.dart';
import 'package:seatup_app/vm/category_provider.dart';
import 'package:seatup_app/vm/curtain_list_provider.dart';
import 'package:seatup_app/vm/curtain_reviews_notifier.dart';
import 'package:seatup_app/vm/weather_provider.dart';

class MainPageHome extends ConsumerWidget {
  const MainPageHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(reviewListProvider); // 후기 목록
    final weatherAsync = ref.watch(weatherProvider); // 날씨 데이터 저장

    final categoryfilter = ref.watch(categoryFilterProvider); // 카테고리 필터
    final curtainAsync = ref.watch(curtainListProvider); // 공연 목록
    final categoryTitle = [
      (category: TicketCategory.musical, label: '뮤지컬'),
      (category: TicketCategory.concert, label: '콘서트'),
      (category: TicketCategory.play, label: '연극'),
      (category: TicketCategory.classic, label: '클래식/무용'),
      (category: TicketCategory.sports, label: '스포츠'),
      (category: TicketCategory.leisure, label: '레저/캠핑'),
      (category: TicketCategory.expo, label: '전시/행사'),
      (category: TicketCategory.kids, label: '아동/가족'),
      (category: TicketCategory.topping, label: 'topping'),
      (category: TicketCategory.benefit, label: '이달의혜택'),
    ];

    // DB type 테이블의 type_seq 매핑
    // 연극=1, 뮤지컬=2, 콘서트=5, 무용=7, 전시=8
    int? _toTypeSeq(TicketCategory category) {
      switch (category) {
        case TicketCategory.play:
          return 1;
        case TicketCategory.musical:
          return 2;
        case TicketCategory.concert:
          return 5;
        case TicketCategory.classic:
          return 7;
        case TicketCategory.expo:
          return 8;

        // DB에 타입이 없거나 아직 준비중이면 null
        case TicketCategory.sports:
        case TicketCategory.leisure:
        case TicketCategory.kids:
        case TicketCategory.topping:
        case TicketCategory.benefit:
          return null;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          // padding: const EdgeInsetsGeometry.all(0),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 550,
                    child: Swiper(
                      itemCount: 3,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            "images/main_swiper_image0${index + 1}.gif",
                            fit: BoxFit.cover,
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
                  padding: EdgeInsets.only(bottom: 20),
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
                _title('장르별 랭킹'),
          
                // --- 가로 카테고리 탭 ---
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: categoryTitle.map((item) {
                      final category = item.category;
                      final isSelected = categoryfilter.category == category;
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(categoryFilterProvider.notifier)
                              .select(
                                category: category,
                                typeSeq: _toTypeSeq(category),
                              );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 14,
                          ),
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // border: Border.all(
                            //   color: isSelected
                            //       ? AppColors.suyellow
                            //       : AppColors.sublack,
                            // ),
                            color: isSelected
                                ? AppColors.suyellow
                                : AppColors.sublack,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.textColor
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          
                // --- 필터된 공연 목록 ---
                SizedBox(
                  height: 340,
                  child: curtainAsync.when(
                    data: (list) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length > 9 ? 9 : list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
          
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Stack(
                                  children: [
                                    // 공연 이미지
                                    Image.network(
                                      item.curtain_pic,
                                      width: double.infinity,
                                      height: 250,
                                      fit: BoxFit.cover,
                                      alignment: AlignmentGeometry.topCenter,
                                    ),
          
                                    // 순위 표시용 숫자 뱃지
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(0, 0, 0, 0.7),
                                          border: Border.all(
                                            color: Colors.white30,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _titleEllipsis(
                                item.title_contents,
                                16,
                                FontWeight.w700,
                              ),
                              _titleEllipsis(
                                item.place_name,
                                14,
                                FontWeight.w400,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    error: (error, _) => Text(error.toString()),
                    loading: () => const CircularProgressIndicator(),
                  ),
                ),
          
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Image.asset('images/main_banner1.jpg'),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Stack(
                    children: [
                      Center(child: _title('베스트 관람후기')),
                      Positioned(
                        right: 0,
                        bottom: -10,
                        child: IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewWrite(),
                            ),
                          ),
                          icon: Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ),
                reviewAsync.when(
                  data: (reviewList) {
                    return reviewList.isEmpty
                        ? Center(child: Text("작성된 리뷰가 없습니다."))
                        : ListView.builder(
                            shrinkWrap: true, // 내용만큼 높이 차지
                            physics:
                                const NeverScrollableScrollPhysics(), // 자체 스크롤 기능 비활성화
                            itemCount: reviewList.length > 5
                                ? 5
                                : reviewList.length,
                            itemBuilder: (context, index) {
                              CurtainReview review = reviewList[index];
                              return ListTile(
                                title: Text(review.title),
                                subtitle: Text(review.content),
                              );
                            },
                          );
                  },
                  error: (error, stackTrace) =>
                      Center(child: Text('오류 : $error')),
                  loading: () => Center(child: CircularProgressIndicator()),
                ),
                weatherAsync.when(
                  data: (weather) {
                    return Column(
                      children: [
                        _title('오늘의 날씨'),
                        const SizedBox(height: 20),
                        _mainWeatherCard(weather),
                        const SizedBox(height: 10),
                        // _minMaxTempCard(weather!),
                        // const SizedBox(height: 20),
                        _weatherInfoGrid(weather),
                      ],
                    );
                  },
                  error: (error, _) => const Text('날씨 정보를 불러오지 못했어요'),
                  loading: () => const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
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

  // 타이틀 위젯 (말줄임 효과)
  Widget _titleEllipsis(String title, double fontSize, FontWeight fontWeight) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

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
                content: Text('준비중입니다.'),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
          }
        },
        child: Column(
          children: [
            Icon(icon, size: 35, color: AppColors.sublack),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
