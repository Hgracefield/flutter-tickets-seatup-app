class Bank {
  int? bank_seq;
  String bank_name;
  String? bank_create_date;

  Bank({
    this.bank_seq,
    required this.bank_name,
    this.bank_create_date,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      bank_seq: json['bank_seq'] ?? 0,
      bank_name: json['bank_name'] ?? "",
      bank_create_date: json['bank_create_date'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_seq': bank_seq,
      'bank_name': bank_name,
      'bank_create_date': bank_create_date,
    };
  }
}