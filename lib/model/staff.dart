class Staff {
  final int? staff_seq;
  final String staff_email;
  final String staff_password;
  final String staff_name;
  final String? staff_address;
  final String? staff_phone;
  
  Staff({
    this.staff_seq,
    required this.staff_email,
    required this.staff_password,
    required this.staff_name,
    this.staff_address,
    this.staff_phone,
  });

  factory Staff.fromJson(Map<String, dynamic> json){
    return Staff(
      staff_seq: json['staff_seq'],
      staff_email: json['staff_email'],
      staff_password: json['staff_password'],
      staff_name: json['staff_name'],
      staff_address: json['staff_address'],
      staff_phone: json['staff_phone'],
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'staff_seq' : staff_seq,
      'staff_email' : staff_email,
      'staff_password' : staff_password,
      'staff_name' : staff_name,
      'staff_address' : staff_address,
      'staff_phone' : staff_phone,
    };
  }
}