class WeatherModel {
  final String? temperature; // T1H, 기온
  final String? tmn; // TMN, 일 최저기온
  final String? tmx; // TMX, 일 최고기온
  final String? tmp; // TMP, 1시간 기온
  final String? humidity;    // REH, 습도
  final String? sky;         // SKY, 하늘 상태
  final String? pty;         // PTY, 강수 형태
  final String? pop;         // POP, 강수 확률
  final String? pcp;         // PCP, 1시간 강수량
  final String? sno;         // SNO, 1시간 신적설

  WeatherModel({
    this.temperature,
    this.tmn,
    this.tmx,
    this.tmp,
    this.humidity,
    this.sky,
    this.pty,
    this.pop,
    this.pcp,
    this.sno,
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
      temperature: find('T1H'),
      tmn: find('TMN'),
      tmx: find('TMX'),
      tmp: find('TMP'),
      humidity: find('REH'),
      sky: find('SKY'),
      pty: find('PTY'),
      pop: find('POP'),
      pcp: find('PCP'),
      sno: find('SNO'),
    );
  }
}