class Location {
  final int location_seq;
  final String location_name;
  final String location_create_date;
  Location({required this.location_seq, required this.location_name, required this.location_create_date});

 // 서버에서 받은 JSON -> Location객체
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      location_seq: json['location_seq'] ?? "",
      location_name: json['location_name'] ?? "",
      location_create_date: json['location_create_date'] ?? "",
    );
  }

  // Location -> Map
  Map<String, dynamic> toJson() {
    return {
      'location_seq': location_seq,
      'location_name': location_name,
      'location_create_date': location_create_date,
    };
  }
}
