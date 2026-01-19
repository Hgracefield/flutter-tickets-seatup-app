class Area {
  int? area_seq;
  String area_number;
  int area_value;
  String? area_create_date;

  Area({
    this.area_seq,
    required this.area_number,
    required this.area_value,
    this.area_create_date
  });

  factory Area.fromJson(Map<String, dynamic> json){
    return Area(
      area_seq: json['area_seq'] ?? 0,
      area_number: json['area_number'] ?? "",
      area_value: json['area_value'] ?? 0,
      area_create_date: json['area_create_date'] ?? "",

    );
  }

  Map<String, dynamic> toJson(){
    return{
      'area_seq' : area_seq,
      'area_number' : area_number,
      'area_value' : area_value,
      'area_create_date' : area_create_date
    };
  }
}