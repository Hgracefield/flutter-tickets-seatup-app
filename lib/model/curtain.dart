class Curtain {
  int? curtain_id;
  String curtain_date;
  String curtain_desc;
  String curtain_mov;
  String curtain_pic;
  String curtain_place;
  String curtain_type;
  String curtain_title;
  int curtain_grade;
  int curtain_area;

  Curtain({
    this.curtain_id,
    required this.curtain_date,
    required this.curtain_desc,
    required this.curtain_mov,
    required this.curtain_pic,
    required this.curtain_place,
    required this.curtain_type,
    required this.curtain_title,
    required this.curtain_grade,
    required this.curtain_area
  });
  
  
  factory Curtain.fromJson(Map<String, dynamic> json){
    return Curtain(
      curtain_id: json['curtain_id'] ?? 0,
      curtain_date: json['curtain_date'] ?? '0',
      curtain_desc: json['curtain_desc'] ?? '',
      curtain_mov: json['curtain_mov'] ?? '',
      curtain_pic: json['curtain_pic'] ?? '',
      curtain_place: json['place_name'] ?? '',
      curtain_type: json['type_name'] ?? '',
      curtain_title: json['title_contents'] ?? '',
      curtain_grade: json['curtain_grade'] ?? 0,
      curtain_area: json['curtain_area'] ?? 0,
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'curtain_id' : curtain_id,
      'curtain_date' : curtain_date,
      'curtain_desc' : curtain_desc,
      'curtain_mov' : curtain_mov,
      'curtain_pic' : curtain_pic,
      'curtain_place' : curtain_place,
      'curtain_type' : curtain_type,
      'curtain_title' : curtain_title,
      'curtain_grade' : curtain_grade,
      'curtain_area' : curtain_area
    };
  }
}