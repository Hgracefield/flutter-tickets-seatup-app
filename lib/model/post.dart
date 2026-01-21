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
      post_seq: json['post_seq'],
      post_user_id: json['post_user_id'] ?? 0,
      user_name: json['user_name'],
      post_curtain_id: json['post_curtain_id'] ?? 0,
      curtain_title: json['title_contents'],
      post_create_date: json['post_create_date'] ?? "",
      post_quantity: json['post_quantity'] ?? 0,
      post_price: json['post_price'] ?? 0,
      post_area: json['post_area'] ?? 0,
      post_grade: json['post_grade'] ?? 0,
      post_desc: json['post_desc'] ?? "",
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