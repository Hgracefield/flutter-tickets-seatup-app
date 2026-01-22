class CurtainReview{
  final String id;
  final String title;
  final String content;

  CurtainReview(
    {
      required this.id,
      required this.title,
      required this.content
    }
  );

  factory CurtainReview.fromMap(Map<String, dynamic> map, String id){
    return CurtainReview(
      id: id,
      title: map['title'] ?? "",
      content: map['content'] ?? ""
    );
  }
}
