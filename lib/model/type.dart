class Type {  
  final String type_name;
  final String type_create_date;

  Type(
    {
      required this.type_name,
      required this.type_create_date,
    }
  );

  // 서버에서 받은 JSON -> Type객체 
  factory Type.fromJson(Map<String, dynamic> json){
    return Type(
      type_name: json['name'] ?? "",
      type_create_date: json['create_date'] ?? "",
    );
  }

  // Type -> Map 
  Map<String, dynamic> toJson(){
    return{
      'name' : type_name,
      'create_date' : type_create_date,
    };
  }
}