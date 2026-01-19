class Grade {
  int? grade_seq;
  String grade_name;
  int grade_value;
  String? grade_create_date;

  Grade({
    this.grade_seq,
    required this.grade_name,
    required this.grade_value,
    this.grade_create_date
  });

  int get bit => 1 << grade_value;

  factory Grade.fromJson(Map<String, dynamic> json){
    return Grade(
      grade_seq: json['grade_seq'] ?? 0,
      grade_name: json['grade_name'] ?? "",
      grade_value: json['grade_value'] ?? 0,
      grade_create_date: json['grade_create_date'] ?? "",

    );
  }

  Map<String, dynamic> toJson(){
    return{
      'grade_seq' : grade_seq,
      'grade_name' : grade_name,
      'grade_value' : grade_value,
      'grade_create_date' : grade_create_date
    };
  }
}