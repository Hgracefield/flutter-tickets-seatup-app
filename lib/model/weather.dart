class WeatherModel {
  final String? tmp; // TMP, 1시간 기온(℃)
  final String? tmn; // TMN, 일 최저기온(℃)
  final String? tmx; // TMX, 일 최고기온(℃)
  final String? reh; // REH, 습도(%)
  final String? sky; // SKY, 하늘 상태
  final String? pty; // PTY, 강수 형태
  final String? pop; // POP, 강수 확률(%)
  final String? pcp; // PCP, 1시간 강수량(mm)

  WeatherModel({
    this.tmp,
    this.tmn,
    this.tmx,
    this.reh,
    this.sky,
    this.pty,
    this.pop,
    this.pcp,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final List items = json['response']['body']['items']['item'];

    String? find(String category) {
      for (final item in items) {
        if (item['category'] == category) {
          return item['fcstValue']?.toString();
        }
      }
      return null;
    }

    return WeatherModel(
      tmp: find('TMP'),
      tmn: find('TMN'),
      tmx: find('TMX'),
      reh: find('REH'),
      sky: find('SKY'),
      pty: find('PTY'),
      pop: find('POP'),
      pcp: find('PCP'),
    );
  }
}
