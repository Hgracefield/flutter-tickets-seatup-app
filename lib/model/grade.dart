class Grade {
  int? grade_seq;
  String grade_name;
  int grade_value;
  int grade_price; // [추가] 해당 등급의 정가 (판매가 제한용)
  String? grade_create_date;

  Grade({
    this.grade_seq,
    required this.grade_name,
    required this.grade_value,
    required this.grade_price, // 추가
    this.grade_create_date,
  });

  // 기존 비트 연산 로직 유지
  int get bit => 1 << grade_value;

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      grade_seq: json['grade_seq'] ?? 0,
      grade_name: json['grade_name'] ?? "",
      grade_value: json['grade_value'] ?? 0,
      // [추가] 서버에서 보내주는 정가 데이터 매핑
      grade_price: json['grade_price'] ?? 0, 
      grade_create_date: json['grade_create_date'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grade_seq': grade_seq,
      'grade_name': grade_name,
      'grade_value': grade_value,
      'grade_price': grade_price, // 추가
      'grade_create_date': grade_create_date,
    };
  }
}