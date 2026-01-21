class Post {
  int? post_seq;
  String? post_create_date;
  int post_user_id;
  String? user_name;
  int post_curtain_id;
  String? curtain_title;
  int post_quantity;
  int post_price;
  int post_area;
  int post_grade;
  String post_desc;

  Post({
    this.post_seq,
    this.post_create_date,
    required this.post_user_id,
    this.user_name,
    required this.post_curtain_id,
    this.curtain_title,
    required this.post_quantity,
    required this.post_price,
    required this.post_area,
    required this.post_grade,
    required this.post_desc,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      post_seq: int.tryParse(json['post_seq']?.toString() ?? ""),
      post_user_id: int.tryParse(json['post_user_id']?.toString() ?? "0") ?? 0,
      user_name: json['user_name'],
      post_curtain_id: int.tryParse(json['post_curtain_id']?.toString() ?? "0") ?? 0,
      curtain_title: json['title_contents'] ?? json['curtain_title'],
      post_create_date: json['post_create_date']?.toString() ?? "",
      post_quantity: int.tryParse(json['post_quantity']?.toString() ?? "0") ?? 0,
      post_price: int.tryParse(json['post_price']?.toString() ?? "0") ?? 0,
      post_area: int.tryParse(json['post_area']?.toString() ?? "0") ?? 0,
      post_grade: int.tryParse(json['post_grade']?.toString() ?? "0") ?? 0,
      post_desc: json['post_desc']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_seq': post_seq,
      'post_user_id': post_user_id,
      'post_curtain_id': post_curtain_id,
      'post_quantity': post_quantity,
      'post_price': post_price,
      'post_area': post_area,
      'post_grade': post_grade,
      'post_desc': post_desc,
    };
  }
}