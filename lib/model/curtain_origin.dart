class CurtainModel {
  int? curtain_id;
  String curtain_date;
  String curtain_time;
  String curtain_desc;
  String curtain_mov;
  String curtain_pic;
  int curtain_place_seq;
  int curtain_type_seq;
  int curtain_title_seq;
  int curtain_grade;
  int curtain_area;

  CurtainModel({
    this.curtain_id,
    required this.curtain_date,
    required this.curtain_time,
    required this.curtain_desc,
    required this.curtain_mov,
    required this.curtain_pic,
    required this.curtain_place_seq,
    required this.curtain_type_seq,
    required this.curtain_title_seq,
    required this.curtain_grade,
    required this.curtain_area,
  });
  
  
  factory CurtainModel.fromJson(Map<String, dynamic> json){
    return CurtainModel(
      curtain_id: json['curtain_id'] ?? 0,
      curtain_date: json['curtain_date'] ?? '0',
      curtain_time: json['curtain_time'] ?? '0',
      curtain_desc: json['curtain_desc'] ?? '',
      curtain_mov: json['curtain_mov'] ?? '',
      curtain_pic: json['curtain_pic'] ?? '',
      curtain_place_seq: json['curtain_place_seq'] ?? 0,
      curtain_type_seq: json['curtain_type_seq'] ?? 0,
      curtain_title_seq: json['curtain_title_seq'] ?? 0,
      curtain_grade: json['curtain_grade'] ?? 0,
      curtain_area: json['curtain_area'] ?? 0,
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'curtain_id' : curtain_id,
      'curtain_date' : curtain_date,
      'curtain_time' : curtain_time,
      'curtain_desc' : curtain_desc,
      'curtain_mov' : curtain_mov,
      'curtain_pic' : curtain_pic,
      'curtain_place_seq' : curtain_place_seq,
      'curtain_type_seq' : curtain_type_seq,
      'curtain_title_seq' : curtain_title_seq,
      'curtain_grade' : curtain_grade,
      'curtain_area' : curtain_area,
    };
  }
}