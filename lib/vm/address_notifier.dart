import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';


class AddressState{
  String? address = "";
  AddressState({this.address});
  AddressState copyWith({String? address})=>AddressState(address: address);
} // AddressState


class AddressNotifier extends Notifier<AddressState>{
  
  @override
  AddressState build() => AddressState();

  Future getAddressFromCoordinates(double lat, double lng) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
  if (placemarks.isNotEmpty) {
    Placemark place = placemarks[0];
    String address = "${place.country}, ${place.administrativeArea}, ${place.locality}, ${place.street}";
    state = state.copyWith(address: address);
  }
}
// DB에 주소가 문자열만 가지고 있어서  주소 -> 좌표(위도 , 경도) 정방향 지오코딩(Forward Geocoding)
  // 길찾기 기능때문에 추가한 함수
  Future<Location?> getCoordinatesFromAddress(String address) async {
    final locations = await locationFromAddress(address);

    if (locations.isEmpty) return null;

    return locations.first; // 여기 안에 latitude, longitude 있음
  }
} // AddressNotifier
 
final addressNotifier = NotifierProvider<AddressNotifier, AddressState>(
  AddressNotifier.new
);


