class Post {
  int? post_seq;
  int post_user_id;
  int post_curtain_id;
  String post_create_date;
  int post_quantity;
  int post_price;

  Post({
    this.post_seq,
    required this.post_user_id,
    required this.post_curtain_id,
    required this.post_create_date,
    required this.post_quantity,
    required this.post_price
  });

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      post_seq: json['post_seq'] ?? 0,
      post_user_id: json['post_user_id'] ?? "",
      post_curtain_id: json['post_curtain_id'] ?? "",
      post_create_date: json['post_create_date'] ?? "",
      post_quantity: json['post_quantity'] ?? "",
      post_price: json['post_price'] ?? "",
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'post_seq' : post_seq,
      'post_user_id' : post_user_id,
      'post_curtain_id' : post_curtain_id,
      'post_create_date' : post_create_date,
      'post_quantity' : post_quantity,
      'post_price' : post_price,
    };
  }
} 