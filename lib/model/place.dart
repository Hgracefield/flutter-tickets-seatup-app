class Place {
  final int? place_seq;
  final String place_name;
  final String? place_create_date;
  final String place_address;

  Place({
    this.place_seq,
    required this.place_name,
    this.place_create_date,
    required this.place_address
  });

  factory Place.fromJson(Map<String, dynamic> json){
    return Place(
      place_seq: json['place_seq'],
      place_name: json['place_name'],
      place_create_date: json['place_create_date'],
      place_address: json['place_address'] ?? ""
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'place_seq' : place_seq,
      'place_name' : place_name,
      'place_create_date' : place_create_date,
      'place_address' : place_address
    };
  }
}