class WeatherModel {
  final String? temperature; // T1H
  final String? humidity;    // REH
  final String? sky;         // SKY
  final String? pty;         // PTY

  WeatherModel({
    this.temperature,
    this.humidity,
    this.sky,
    this.pty,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final List items =
        json['response']['body']['items']['item'];

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
      humidity: find('REH'),
      sky: find('SKY'),
      pty: find('PTY'),
    );
  }
}
