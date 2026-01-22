class Purchase {
  final int? purchase_seq;
  final int purchase_user_id;
  final int purchase_post_id;
  final String? purchase_date;
  final String purchase_create_date;

  Purchase({
    this.purchase_seq,
    required this.purchase_user_id,
    required this.purchase_post_id,
    this.purchase_date,
    required this.purchase_create_date
  });

  factory Purchase.fromJson(Map<String, dynamic> json){
    return Purchase(
      purchase_user_id: json['purchase_user_id'],
      purchase_post_id: json['purchase_post_id'],
      purchase_create_date: json['purchase_create_date']
    );
  }

  Map<String, dynamic> toInsertJson() {
  return {
    'purchase_user_id': purchase_user_id,
    'purchase_post_id': purchase_post_id,
    'purchase_create_date': purchase_create_date,
  };
}


}