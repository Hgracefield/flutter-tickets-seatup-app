// 길찾기에 필요한 값만 모델 따로 생성 pjs
class UserAddress {
  final int userId;
  final String userAddress;

  UserAddress({required this.userId, required this.userAddress});

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      userId: json['user_id'],
      userAddress: json['user_address'] ?? '',
    );
  }
}

class PlaceAddress {
  final int placeSeq;
  final String placeName;
  final String placeAddress;

  PlaceAddress({
    required this.placeSeq,
    required this.placeName,
    required this.placeAddress,
  });

  factory PlaceAddress.fromJson(Map<String, dynamic> json) {
    return PlaceAddress(
      placeSeq: json['place_seq'],
      placeName: json['place_name'] ?? '',
      placeAddress: json['place_address'] ?? '',
    );
  }
}
