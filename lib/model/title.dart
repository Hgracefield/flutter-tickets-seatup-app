class Title {
  final int? title_seq;
  final String title_contents;
  final String? title_create_date;

  Title({
    this.title_seq,
    required this.title_contents,
    this.title_create_date,
  });

  factory Title.fromJson(Map<String, dynamic> json){
    return Title(
      title_seq: json['title_seq'],
      title_contents: json['title_contents'],
      title_create_date: json['title_create_date']
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'title_seq' : title_seq,
      'title_contents' : title_contents,
      'title_create_date' : title_create_date
    };
  }
}