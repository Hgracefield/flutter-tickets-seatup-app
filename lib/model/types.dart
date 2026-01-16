class Types {  
  final String type_name;
  final String type_create_date;

  Types(
    {
      required this.type_name,
      required this.type_create_date
    }
  );

  // 서버에서 받은 JSON -> Type객체 
  factory Types.fromJson(Map<String, dynamic> json){
    return Types(
      type_name: json['type_name'] ?? "",
      type_create_date: json['type_create_date'] ?? "",
    );
  }

  // Type -> Map 
  Map<String, dynamic> toJson(){
    return{
      'type_name' : type_name,
      'type_create_name' : type_create_date,
    };
  }
}