class Keyword {
  int? id;
  String word;
  String createDate;
  Keyword({this.id, required this.word, required this.createDate});

  factory Keyword.fromMap(Map<String, dynamic> map) {
    return Keyword(
      id: map['id'] as int?,
      word: map['word'] ?? "",
      createDate: map['createDate'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'createDate': createDate,
    };
  }
}