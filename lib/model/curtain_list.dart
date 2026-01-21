class CurtainList {
  final int curtain_id;
  final int title_seq;
  final String title_contents;
  final String curtain_pic;
  final String place_name;

  CurtainList({
    required this.curtain_id,
    required this.title_seq,
    required this.title_contents,
    required this.curtain_pic,
    required this.place_name,
  });

  factory CurtainList.fromJson(Map<String, dynamic> json) {
    return CurtainList(
      curtain_id: json["curtain_id"] ?? 0,
      title_seq: json["title_seq"] ?? 0,
      title_contents: json["title_contents"] ?? "제목 정보 없음",
      curtain_pic: json["curtain_pic"] ?? "",
      place_name: json["place_name"] ?? "",
    );
  }
}